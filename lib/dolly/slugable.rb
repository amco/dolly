# frozen_string_literal: true

module Dolly
  module Slugable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def slug
      slugable_properties.
        map(&normalize_property).
        map(&parameterize_item).
        join(slugable_separator)
    end

    def parameterize_item
      proc do |message|
        if message.respond_to?(:parameterize)
          next message.parameterize
        end

        message
      end
    end

    def id
      doc[:_id] ||= self.class.namespace_key(slug)
    end

    def normalize_property
      proc do |property|
        send(:"#{property}").to_s
      end
    end

    module ClassMethods
      DEFAULT_SEPARATOR = '_'

      def set_slug(*slugable_properties, separator: DEFAULT_SEPARATOR)
        validate_slug_property_presence!(slugable_properties)
        define_method(:slugable_separator) { separator }
        define_method(:slugable_properties) { slugable_properties }
      end

      def validate_slug_property_presence!(slugable_properties)
        missing_properties = slugable_properties.select do |prop|
          !instance_methods(false).include?(prop)
        end

        unless missing_properties.empty?
          raise Dolly::MissingSlugableProperties, missing_properties
        end
      end
    end
  end
end
