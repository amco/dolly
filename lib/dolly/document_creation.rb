require 'dolly/properties'
require 'dolly/framework_helper'

module Dolly
  module DocumentCreation
    include Properties
    include FrameworkHelper

    def from_doc(doc)
      attributes = property_clean_doc(doc)

      new(attributes).tap do |model|
        model.send(:doc).merge!(doc)
      end
    end

    def from_json(json)
      raw_data = Oj.load(json, symbol_keys: true)
      data = rails? ? raw_data.with_indifferent_access : raw_data
      from_doc(data)
    end

    def create(attributes)
      new(attributes).tap { |model| model.save }
    end
  end
end
