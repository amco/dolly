require "dolly/connection"
require "dolly/collection"
require "dolly/name_space"
require "exceptions/dolly"

module Dolly
  module Query
    module ClassMethods
      include Dolly::NameSpace
      include Dolly::Connection
      attr_accessor :properties

      DESIGN_DOC = "dolly"

      def find *keys
        query_hash = { keys: keys.map{|key| namespace key} }

        if keys.count > 1
          build_collection( query_hash )
        else
          self.new.from_response(database.all_docs(query_hash))
        end
      rescue NoMethodError => err
        if err.message == "undefined method `[]' for nil:NilClass"
          raise Dolly::ResourceNotFound
        else
          raise
        end
      end

      def default_query_args
        {startkey: "#{name_paramitized}/", endkey: "#{name_paramitized}/\ufff0"}
      end

      def all
        build_collection default_query_args
      end

      def first limit = 1
        res = build_collection default_query_args.merge( limit: 1)
        limit == 1 ? res.first : res
      end

      def last limit = 1
        res = build_collection({startkey: default_query_args[:endkey], endkey: default_query_args[:startkey], limit: limit, descending: true})
        limit == 1 ? res.first : res
      end

      def build_collection q
        res = database.all_docs(q)
        Collection.new res, name_for_class
      end

      def find_with doc, view_name, opts = {}
        res = view "_design/#{doc}/_view/#{view_name}", opts
        Collection.new res, name_for_class
      end

      #TODO: new implementation for collection returning
      # multiple types is failling when the class has a namespace
      # as the namespace does not exists on the doc id
      # we need to reimplement this through a references class method.
      def name_for_class
        if name.include? '::'
          name.constantize
        end
      end

      def view doc, options = {}
        options.merge! include_docs: true
        database.get doc, options
      end

      def raw_view doc, view, opts = {}
        database.get("_design/#{doc}/_view/#{view}", opts)
      end

    end

    def self.included(base)
      base.extend ClassMethods
    end

  end
end
