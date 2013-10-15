require "active_model/naming"
require "dolly/connection"
require "dolly/collection"
require "dolly/representations/document_representation"
require "dolly/representations/collection_representation"
require "exceptions/dolly"

module Dolly
  module Document

    def id
      doc['_id']
    end

    def rev
      doc['_rev']
    end

    def from_json string
      self.class.new.extend(representation).from_json( string )
    end

    def representation
      Representations::DocumentRepresentation.config(self.class.properties)
    end

    module ClassMethods
      include ActiveModel::Naming
      include Dolly::Connection
      attr_accessor :properties

      DESIGN_DOC = "dolly"

      def find *ids
        response = default_view(keys: ids.map{|id| namespace(id)}).parsed_response
        ids.count > 1 ? Collection.new(response, name.constantize) : self.new.from_json(response)
      rescue NoMethodError => err
        if "undefined method `[]' for nil:NilClass"
          raise Dolly::ResourceNotFound
        else
          raise
        end
      end

      def all
        Collection.new default_view.parsed_response, name.constantize
      end

      def default_view options = {}
        view default_doc, options
      end

      def view doc, options = {}
        options.merge! include_docs: true
        database.get doc, options
      end

      def default_doc
        "#{design_doc}/_view/#{name_paramitized}"
      end

      def design_doc
        "_design/#{@design_doc || DESIGN_DOC}"
      end

      def set_design_doc value
        @design_doc = value
      end

      def name_paramitized
        model_name.param_key
      end

      def namespace id
        return id if id =~ /^#{name_paramitized}/
        "#{name_paramitized}/#{id}"
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
