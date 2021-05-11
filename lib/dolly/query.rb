require 'dolly/collection'
require 'dolly/query_arguments'
require 'dolly/document_type'
require 'refinements/string_refinements'

module Dolly
  module Query
    include QueryArguments
    include DocumentType

    using StringRefinements

    def find *keys
      query_hash = { keys: namespace_keys(keys) }

      build_collection(query_hash).first_or_all&.itself ||
        raise(Dolly::ResourceNotFound)
    end

    def find_all(*keys)
      query_hash = { keys: namespace_keys(keys) }
      return [] if query_hash[:keys].none?

      keys_to_find_counter = query_hash[:keys].length
      build_collection(query_hash).first_or_all(true)&.itself
    end

    def safe_find *keys
      find *keys
    rescue Dolly::ResourceNotFound
      nil
    end

    def all
      build_collection(default_query_args)
    end

    def first limit = 1
      query_hash = default_query_args.merge(limit: limit)
      build_collection(query_hash).first_or_all(limit > 1)
    end

    def last limit = 1
      query_hash = descending_query_args.merge(limit: limit)
      build_collection(query_hash).first_or_all(limit > 1)
    end

    def find_with doc, view_name, opts = {}
      opts          = opts.each_with_object({}) { |(k, v), h| h[k] = v }
      query_results = raw_view(doc, view_name, opts)

      Collection.new({ rows: query_results, options: {} }).first_or_all
    end

    def build_collection(query)
      Collection.new({ rows: connection.get('_all_docs', query.merge(include_docs: true)), options: { doc_type: self.class_name }})
    end

    def bulk_document
      BulkDocument.new(connection)
    end
  end
end
