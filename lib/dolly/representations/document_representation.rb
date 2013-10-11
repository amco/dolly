require 'representable/json'

module Dolly
  module Representations
    module DocumentRepresentation
      include Representable::JSON

      property :rows
      property :doc

      def self.config properties
        properties.each do |p|
          self.property p
        end
        self
      end
    end
  end
end
