# frozen_string_literal: true

require 'dolly/properties'
require 'dolly/framework_helper'

module Dolly
  module DocumentCreation
    include Properties
    include FrameworkHelper

    def from_doc(doc)
      attributes = property_clean_doc(doc)

      new(attributes).tap do |model|
        doc.each_key do |key|
          if model.respond_to?(:"#{key}=")
            model.send(:"#{key}=", doc[key])
          else
            model.send(:doc)[key] = doc[key]
          end
        end
      end
    end

    def from_json(json)
      raw_data = Oj.load(json, symbol_keys: true)
      data = rails? ? data.with_indifferent_access : raw_data
      from_doc(data)
    end

    def create(attributes)
      new(attributes).tap(&:save)
    end
  end
end
