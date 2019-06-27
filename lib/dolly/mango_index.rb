# frozen_string_literal: true

require 'forwardable'
require 'dolly/document'

module Dolly
  class MangoIndex
    class << self
      extend Forwardable

      DESIGN = '_index'

      def_delegators :connection, :get, :post, :delete_index

      def all
        get(DESIGN)[:indexes]
      end

      def create(name, fields, type = 'json')
        post(DESIGN, build_index_structure(name, fields, type))
      end

      def find_by_fields(fields)
        all.find do |index_doc|
          index_doc.dig(:def, :fields).map(&:keys).flatten == fields
        end
      end

      def delete_all
        all.each do |index_doc|
          next if index_doc[:ddoc].nil?
          delete(index_doc)
        end
      end

      def delete(index_doc)
        resource = "#{DESIGN}/#{index_doc[:ddoc]}/json/#{index_doc[:name]}"

        delete_index(resource)
      end

      private

      def connection
        @connection ||= Dolly::Document.connection
      end

      def build_index_structure(name, fields, type)
        {
          index: {
            fields: fields
          },
          name: name,
          type: type
        }
      end
    end
  end
end
