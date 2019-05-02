require 'dolly/query'
require 'dolly/connection'
require 'dolly/request'
require 'dolly/depracated_database'
require 'dolly/document_state'
require 'dolly/properties'
require 'dolly/identity_properties'
require 'dolly/attachment'
require 'dolly/property'
require 'dolly/timestamp'

module Dolly
  class Document
    extend Query
    extend Request
    extend DepracatedDatabase
    extend Properties
    include Property
    include Timestamp
    include DocumentState
    include IdentityProperties
    include Attachment

    attr_writer :doc

    class << self
      def from_doc(doc)
        required_properties = doc.select { |key, value| properties.include? key }
        new(required_properties).tap { |d| d.doc = doc }
      end

      def from_json(json)
        from_doc(JSON.parse(json, symbolize_names: true))
      end

      def create(attributes)
        new(attributes).tap { |doc| doc.save }
      end
    end

    def initialize attributes = {}
      attributes.each(&build_property)
    end

    def database
      self.class.connection
    end

    protected

    def doc
      @doc ||= {}
    end
  end
end
