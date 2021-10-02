require 'dolly/properties'

module Dolly
  module DocumentCreation
    include Properties

    def from_doc(doc)
      attributes = property_clean_doc(doc)
      new(attributes).tap { |model| model.doc = doc }
    end

    def from_json(json)
      raw_data = Oj.load(json, symbol_keys: true)
      data = defined?(ActiveSupport::HashWithIndifferentAccess) ? data.with_indifferent_access : raw_data
      from_doc(data)
    end

    def create(attributes)
      new(attributes).tap { |model| model.save }
    end
  end
end
