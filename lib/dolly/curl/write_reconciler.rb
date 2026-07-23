# frozen_string_literal: true

require 'dolly/curl/document_helper'
require 'dolly/exceptions'
require 'dolly/curl/response_formatter'
require 'dolly/curl/stale_connection'

module Dolly
  module Curl
    # Reconciles ambiguous CouchDB writes after stale keep-alive failures.
    # Depends on a transport that responds to +perform+ and +discard_handle+.
    class WriteReconciler
      include ResponseFormatter

      def initialize(transport:, reader:, db_name:)
        @transport = transport
        @reader = reader
        @documents = DocumentHelper.new(db_name: db_name)
      end

      def reconcile(method, uri, data, error, &block)
        case method.to_sym
        when :put then reconcile_put(uri, data, error, &block)
        when :delete then reconcile_delete(uri, data, error, &block)
        when :post then reconcile_post(uri, data, error, &block)
        else raise_ambiguous(method, uri, error)
        end
      end

      private

      attr_reader :transport, :reader, :documents

      def reconcile_post(uri, data, error, &block)
        return reconcile_bulk_docs(uri, data, error, &block) if bulk_docs?(uri)

        raise_ambiguous(:post, uri, error)
      end

      def reconcile_put(uri, data, error, &block)
        doc_id, intended = put_target(uri, data, error)
        resolve_put(uri, data, doc_id, intended, error, &block)
      rescue *StaleConnection::ERRORS => retry_error
        transport.discard_handle
        raise_ambiguous(:put, uri, retry_error)
      end

      def put_target(uri, data, error)
        doc_id = documents.id_from_uri(uri)
        raise_ambiguous(:put, uri, error) unless doc_id

        intended = documents.normalize(data)
        raise_ambiguous(:put, uri, error) unless intended

        [doc_id, intended]
      end

      def resolve_put(uri, data, doc_id, intended, error, &block)
        stored = reader.fetch_document(doc_id)
        return put_success(stored) if put_already_applied?(stored, intended)
        return transport.perform(:put, uri, data, &block) if put_retryable?(stored, intended)

        raise_ambiguous(:put, uri, error)
      end

      def put_already_applied?(stored, intended)
        stored && documents.matches?(stored, intended)
      end

      def put_retryable?(stored, intended)
        return documents.revision(intended).nil? if stored.nil?

        revision = documents.revision(intended)
        revision && documents.value(stored, :_rev) == revision
      end

      def put_success(stored)
        {
          ok: true,
          id: documents.value(stored, :_id),
          rev: documents.value(stored, :_rev)
        }
      end

      def reconcile_delete(uri, data, error, &block)
        doc_id = documents.id_from_uri(uri)
        raise_ambiguous(:delete, uri, error) unless doc_id

        expected_rev = documents.rev_from_uri(uri)
        raise_ambiguous(:delete, uri, error) unless expected_rev

        resolve_delete(uri, data, doc_id, expected_rev, error, &block)
      rescue *StaleConnection::ERRORS => retry_error
        transport.discard_handle
        raise_ambiguous(:delete, uri, retry_error)
      end

      def resolve_delete(uri, data, doc_id, expected_rev, error, &block)
        stored = reader.fetch_document(doc_id)
        return { ok: true, id: doc_id } if stored.nil?
        return { ok: true, id: doc_id } if documents.deleted?(stored)
        return transport.perform(:delete, uri, data, &block) if documents.value(stored, :_rev) == expected_rev

        raise_ambiguous(:delete, uri, error)
      end

      def reconcile_bulk_docs(uri, data, error, &block)
        docs = documents.docs_from_bulk_payload(data)
        raise_ambiguous(:post, uri, error) if docs.empty?

        ids = docs.map { |doc| documents.id(doc) }.compact
        raise_ambiguous(:post, uri, error) if ids.empty? || ids.size != docs.size

        classify_and_retry_bulk(uri, docs, ids, error, &block)
      rescue *StaleConnection::ERRORS => retry_error
        transport.discard_handle
        raise_ambiguous(:post, uri, retry_error)
      end

      def classify_and_retry_bulk(uri, docs, ids, error, &block)
        rows_by_id = reader.fetch_documents_by_ids(ids)
        results = []
        pending = []

        docs.each do |doc|
          row = rows_by_id[documents.id(doc)]
          stored = row && row[:doc]

          if bulk_committed?(doc, stored, row)
            results << bulk_success(doc, stored)
          elsif bulk_unapplied?(doc, stored)
            pending << doc
          else
            raise_ambiguous(:post, uri, error)
          end
        end

        results.concat(retry_pending_bulk(uri, pending, &block)) if pending.any?
        results
      end

      def retry_pending_bulk(uri, pending, &block)
        retry_response = transport.perform(:post, uri, { docs: pending }, &block)
        retry_results = response_format(retry_response, :post)
        retry_results = [retry_results] unless retry_results.is_a?(Array)
        retry_results
      end

      def bulk_committed?(intended, stored, row)
        return true if documents.deleted?(intended) && bulk_deleted?(stored, row)
        return false if stored.nil?

        documents.matches?(stored, intended)
      end

      def bulk_deleted?(stored, row)
        stored.nil? || documents.deleted?(stored) || row&.dig(:value, :deleted)
      end

      def bulk_unapplied?(intended, stored)
        return true if stored.nil? && !documents.deleted?(intended)
        return true if delete_still_present?(intended, stored)
        return true if update_still_at_source_rev?(intended, stored)

        false
      end

      def delete_still_present?(intended, stored)
        documents.deleted?(intended) &&
          stored &&
          !documents.deleted?(stored) &&
          documents.value(stored, :_rev) == documents.revision(intended)
      end

      def update_still_at_source_rev?(intended, stored)
        !documents.deleted?(intended) &&
          stored &&
          documents.revision(intended) &&
          documents.value(stored, :_rev) == documents.revision(intended)
      end

      def bulk_success(intended, stored)
        id = documents.id(intended)
        return deleted_bulk_success(id, stored) if documents.deleted?(intended)

        { ok: true, id: id, rev: documents.value(stored, :_rev) }
      end

      def deleted_bulk_success(id, stored)
        result = { ok: true, id: id }
        rev = stored && documents.value(stored, :_rev)
        result[:rev] = rev if rev
        result
      end

      def bulk_docs?(uri)
        uri.path.end_with?('/_bulk_docs')
      end

      def raise_ambiguous(method, uri, error)
        raise Dolly::AmbiguousWriteError.new(method: method, uri: uri, cause: error)
      end
    end
  end
end
