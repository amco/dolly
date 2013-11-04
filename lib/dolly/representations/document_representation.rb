require 'representable/json'
require 'dolly/representations/tools'

module Dolly
  module Representations
    module DocumentRepresentation
      include Representable::JSON
      include Dolly::Representations::Tools

      clean_representables
      property :doc

      def self.config properties
        self.clean_representables
        self.property :doc
        properties.each {|p| self.property p.name}
        self
      end

    end
  end
end
