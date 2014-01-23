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
        response = database.all_docs( keys: keys.map{|key| namespace key} ).parsed_response
        keys.count > 1 ? Collection.new(response, name.constantize) : self.new.from_json(response)
      rescue NoMethodError => err
        if err.message == "undefined method `[]' for nil:NilClass"
          raise Dolly::ResourceNotFound
        else
          raise
        end
      end

      def default_query_args
        {startkey: "#{name_paramitized}/", endkey: "#{name_paramitized}/{}"}
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
        Collection.new res.parsed_response, name.constantize
      end

      def find_with doc, view_name, opts = {}
        res = view "_design/#{doc}/_view/#{view_name}", opts
        Collection.new res.parsed_response, name.constantize
      end

      def view doc, options = {}
        options.merge! include_docs: true
        database.get doc, options
      end

      def timestamps!
        %i/created_at updated_at/.each do |method|
          define_method(method){ @doc[method.to_s] ||= DateTime.now }
          define_method(:"[]"){|m| self.send(m.to_sym) }
          define_method(:"[]="){|m, v| self.send(:"#{m}=", v) }
          define_method(:"#{method}="){|val| @doc[method.to_s] = val }
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

  end
end
