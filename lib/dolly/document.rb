require 'dolly/mango'
require 'dolly/mango_index'
require 'dolly/query'
require 'dolly/view_query'
require 'dolly/connection'
require 'dolly/request'
require 'dolly/depracated_database'
require 'dolly/document_state'
require 'dolly/properties'
require 'dolly/document_type'
require 'dolly/identity_properties'
require 'dolly/attachment'
require 'dolly/property_manager'
require 'dolly/timestamp'
require 'dolly/query_arguments'
require 'dolly/document_creation'
require 'dolly/class_methods_delegation'
require 'dolly/framework_helper'
require 'refinements/string_refinements'

module Dolly
  class Document
    extend Mango
    extend Query
    extend ViewQuery
    extend Request
    extend DepracatedDatabase
    extend Properties
    extend DocumentCreation

    include DocumentType
    include PropertyManager
    include Timestamp
    include DocumentState
    include IdentityProperties
    include Attachment
    include QueryArguments
    include ClassMethodsDelegation
    include FrameworkHelper

    attr_writer :doc

    def initialize(attributes = {})
      init_ancestor_properties
      properties.each(&build_property(attributes))
    end

    protected

    def doc
      @doc ||= doc_for_framework
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

    def doc_for_framework
      return {} unless rails?
      {}.with_indifferent_access
    end
  end
end
