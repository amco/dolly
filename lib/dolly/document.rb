require 'dolly/mango'
require 'dolly/mango_index'
require 'dolly/query'
require 'dolly/connection'
require 'dolly/request'
require 'dolly/depracated_database'
require 'dolly/document_state'
require 'dolly/properties'
require 'dolly/identity_properties'
require 'dolly/attachment'
require 'dolly/property_manager'
require 'dolly/timestamp'
require 'dolly/query_arguments'
require 'dolly/document_creation'
require 'dolly/class_methods_delegation'
require 'refinements/string_refinements'

module Dolly
  class Document
    extend Mango
    extend Query
    extend Request
    extend DepracatedDatabase
    extend Properties
    extend DocumentCreation

    include PropertyManager
    include Timestamp
    include DocumentState
    include IdentityProperties
    include Attachment
    include QueryArguments
    include ClassMethodsDelegation

    attr_writer :doc

    def initialize(attributes = {})
      init_ancestor_properties
      properties.each(&build_property(attributes))
    end

    protected

    def doc
      @doc ||= {}
    end

    def init_ancestor_properties
      self.class.ancestors.map do |ancestor|
        begin
          ancestor.properties.entries.each do |property|
            properties << property
          end
        rescue NoMethodError => e
        end
      end
    end
  end
end
