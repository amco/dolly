# frozen_string_literal: true

require 'dolly/document'

module Dolly
  class MangoIndex
    class << self
      DESIGN = '_index'

      def all
        Dolly::Document.connection.get(DESIGN)[:indexes]
      end

      def create(name, fields, type = 'json')
        Dolly::Document.connection.post(DESIGN, build_index_structure(name, fields, type))
      end

      def find_by_fields(fields)
        all.find do |index_doc|
          index_doc.dig(:def, :fields).map(&:keys).flatten == fields
        end
      end

      def delete_all
        all.each do |index_doc|
          delete(index_doc)
        end
      end

      private

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
