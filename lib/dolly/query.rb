require 'dolly/collection'

module Dolly
  module Query
    def find *keys
      query_hash = { keys: namespace_keys(keys) }
      build_collection(query_hash)
    end

    def all
      build_collection(default_query_args)
    end

    def first limit = 1
      query_hash = default_query_args.merge(limit: limit)
      build_collection(query_hash)
    end

    def last limit = 1
      query_hash = { startkey: default_query_args[:endkey], endkey: default_query_args[:startkey], limit: limit, descending: true, include_docs: true }
      build_collection(query_hash)
    end

    def find_with doc, view_name, opts = {}
      Collection.new(raw_view(doc, view_name, opts.merge(include_docs: true))).first_or_all
    end

    def raw_view doc, view_name, opts = {}
      design = "_design/#{doc}/_view/#{view}"
      connection.view design, opts
    end

    def build_collection(query)
      Collection.new(connection.get('_all_docs', query.merge(include_docs: true))).first_or_all
    end

    def namespace_keys(keys)
      keys.map { |key| namespace_key key }
    end

    def namespace_key(key)
      return key if key =~ %r{^#{name_paramitized}/}
      "#{name_paramitized}/#{key}"
    end

    private

    def default_query_args
      { startkey: "#{name_paramitized}/", endkey: URI.escape("#{name_paramitized}/\ufff0") }
    end

    def name_paramitized
      underscore name.split("::").last
    end

    #FROM ActiveModel::Name
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
