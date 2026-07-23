# frozen_string_literal: true

require 'cgi'
require 'oj'

module Dolly
  module Curl
    # Document identity, URI parsing, and equality helpers for write reconciliation.
    class DocumentHelper
      IGNORED_COMPARE_KEYS = %i[_rev].freeze

      def initialize(db_name:)
        @db_name = db_name
      end

      def id_from_uri(uri)
        prefix = "/#{@db_name}/"
        path = uri.path
        return nil unless path.start_with?(prefix)

        rest = path[prefix.length..-1]
        return nil if rest.nil? || rest.empty?
        return nil if rest.start_with?('_')
        return nil if rest.include?('/')

        CGI.unescape(rest)
      end

      def rev_from_uri(uri)
        return nil unless uri.query

        CGI.parse(uri.query)['rev']&.first
      end

      def normalize(data)
        return data.transform_keys(&:to_sym) if data.is_a?(Hash)
        return nil if data.nil?

        parsed = data.is_a?(String) ? Oj.load(data, symbol_keys: true) : nil
        parsed.is_a?(Hash) ? parsed : nil
      rescue Oj::ParseError
        nil
      end

      def matches?(stored, intended)
        intended.each do |key, expected|
          key = key.to_sym
          next if IGNORED_COMPARE_KEYS.include?(key)
          return false unless value(stored, key) == expected
        end
        true
      end

      def value(doc, key)
        return doc[key] if doc.key?(key)
        return doc[key.to_s] if doc.key?(key.to_s)

        nil
      end

      def id(doc)
        value(doc, :_id)
      end

      def revision(doc)
        value(doc, :_rev)
      end

      def deleted?(doc)
        value(doc, :_deleted)
      end

      def docs_from_bulk_payload(data)
        payload = normalize(data)
        return [] unless payload

        Array(payload[:docs]).map { |doc| normalize(doc) }.compact
      end
    end
  end
end
