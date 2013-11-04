require 'representable/json'
require 'dolly/representations/tools'

module Dolly
  module Representations
    module CollectionRepresentation
      include Representable::JSON
      include Dolly::Representations::Tools

      clean_representables

      def self.config docs_class
        properties = docs_class.send(:properties)
        self.collection :rows, extend: DocumentRepresentation.config(properties), class: docs_class
        self
      end
    end
  end
end

