require 'dolly/collection'
require 'dolly/query_arguments'
require 'dolly/document_type'

module Dolly
  module Query
    include QueryArguments
    include DocumentType

    def find *keys
      query_hash = { keys: namespace_keys(keys) }

      build_collection(query_hash).first_or_all&.itself ||
        raise(Dolly::ResourceNotFound)
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
      opts          = opts.each_with_object({}) { |(k, v), h| h[k] = escape_value(v) }
      query_results = raw_view(doc, view_name, opts)

      Collection.new(query_results).first_or_all
    end

    def raw_view doc, view_name, opts = {}
      design = "_design/#{doc}/_view/#{view_name}"
      connection.view(design, opts)
    end

    def build_collection(query)
      Collection.new(connection.get('_all_docs', query.merge(include_docs: true)))
    end

    def bulk_document
      BulkDocument.new(connection)
    end
  end
end
