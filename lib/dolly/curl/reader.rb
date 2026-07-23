# frozen_string_literal: true

require 'cgi'
require 'dolly/exceptions'

module Dolly
  module Curl
    # Reads CouchDB state for write reconciliation via Connection's public API.
    class Reader
      def initialize(connection)
        @connection = connection
      end

      def fetch_document(doc_id)
        @connection.request(:get, CGI.escape(doc_id.to_s))
      rescue Dolly::ResourceNotFound
        nil
      end

      def fetch_documents_by_ids(ids)
        response = @connection.post('_all_docs', keys: ids, query: { include_docs: true })
        rows = response[:rows] || []
        rows.each_with_object({}) do |row, memo|
          memo[row[:id] || row[:key]] = row
        end
      end
    end
  end
end
