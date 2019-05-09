require 'dolly/properties'

module Dolly
  module DocumentCreation
    include Properties

    def from_doc(doc)
      attributes = property_clean_doc(doc)
      new(attributes).tap { |model| model.doc = doc }
    end

    def from_json(json)
      from_doc(JSON.parse(json, symbolize_names: true))
    end

    def create(attributes)
      new(attributes).tap { |model| model.save }
    end
  end
end
