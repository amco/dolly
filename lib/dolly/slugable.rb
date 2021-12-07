module Dolly
  module Slugable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def slug
      slugable_properties.
        map{ |property| send(:"#{property}").to_s }.
        map(&parameterize_item).
        join(slugable_separator)
    end

    def parameterize_item
      proc do |msg|
        next msg.parameterize if msg.respond_to?(:parameterize)
        msg
      end
    end

    def id
      doc[:_id] ||= self.class.namespace_key(slug)
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

      def callback_cond(condition)
        return condition unless condition.is_a?(Symbol)
        send(condition)
      end
    end
  end
end
