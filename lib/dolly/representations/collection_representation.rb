require 'representable/json'

module Dolly
  module Representations
    module CollectionRepresentation
      include Representable::JSON

      def self.config docs_class
        self.collection :rows, extend: DocumentRepresentation, class: docs_class
        self
      end
    end
  end
end

