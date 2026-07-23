# frozen_string_literal: true

require 'curb'
require 'cgi'
require 'dolly/curl/stale_connection'
require 'dolly/curl/write_reconciler'

module Dolly
  module Curl
    # Thread-local Curb transport with stale-connection handling.
    #
    # Reuses one ::Curl::Easy handle per thread, retries safe reads once, and
    # delegates ambiguous writes to WriteReconciler.
    #
    # Assumes one in-flight request per thread (not safe under fiber-based servers).
    #
    # +reader+ must respond to:
    # - fetch_document(doc_id) -> Hash or nil
    # - fetch_documents_by_ids(ids) -> Hash keyed by id
    class Connection
      MAX_STALE_RETRIES = 1
      THREAD_STORE_KEY = :dolly_curl_easy
      READ_ONLY_POST_SUFFIXES = %w[/_find /_all_docs].freeze

      attr_reader :db_name, :reader

      def initialize(db_name:, reader:, reconciler: nil)
        @db_name = db_name
        @reader = reader
        @reconciler = reconciler
      end

      def request(method, uri, data = nil, retries = 0, &block)
        perform(method, uri, data, &block)
      rescue *StaleConnection::ERRORS => error
        discard_handle

        if safe_to_retry?(method, uri)
          raise error if retries >= MAX_STALE_RETRIES

          return request(method, uri, data, retries + 1, &block)
        end

        reconciler.reconcile(method, uri, data, error, &block)
      end

      def perform(method, uri, data = nil, &block)
        handle = prepare_handle(uri, &block)
        dispatch_http(handle, method, data)
        handle
      end

      def discard_handle
        store = Thread.current[THREAD_STORE_KEY]
        return unless store

        handle = store.delete(self.class)
        handle&.close
      rescue StandardError
        nil
      end

      def thread_local_handle
        store = Thread.current[THREAD_STORE_KEY] ||= {}
        handle = store[self.class]
        return handle unless handle.nil? || mocked_curl_class?(handle)

        begin
          handle&.close
        rescue StandardError
          nil
        end

        store[self.class] = ::Curl::Easy.new
      end

      private

      def mocked_curl_class?(handle)
        !handle.instance_of?(::Curl::Easy)
      end

      def reconciler
        @reconciler ||= WriteReconciler.new(
          transport: self,
          reader: reader,
          db_name: db_name
        )
      end

      def prepare_handle(uri)
        handle = thread_local_handle
        handle.reset
        handle.url = uri.to_s
        handle.headers['Content-Type'] = 'application/json'
        handle.headers['Accept'] = 'application/json'
        yield handle if block_given?
        handle
      end

      def dispatch_http(handle, method, data)
        case method.to_sym
        when :head then handle.http_head
        when :delete then handle.http_delete
        when :get then http_get(handle, data)
        when :post then handle.http_post(payload_json(data))
        when :put then handle.http_put(payload_json(data))
        else
          raise ArgumentError, "unsupported HTTP method: #{method}"
        end
      end

      def http_get(handle, data)
        apply_get_query!(handle, data)
        handle.http_get
      end

      def payload_json(data)
        return data if data.is_a?(String)

        data.to_json
      end

      def apply_get_query!(handle, data)
        return if data.nil? || data.empty?

        query = data.map do |key, value|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end.join('&')
        separator = handle.url.include?('?') ? '&' : '?'
        handle.url = "#{handle.url}#{separator}#{query}"
      end

      def safe_to_retry?(method, uri)
        case method.to_sym
        when :get, :head
          true
        when :post
          read_only_post?(uri)
        else
          false
        end
      end

      def read_only_post?(uri)
        READ_ONLY_POST_SUFFIXES.any? { |suffix| uri.path.end_with?(suffix) }
      end
    end
  end
end
