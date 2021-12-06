require 'dolly/property_set'
require  'dolly/property'

module Dolly
  module Properties
    SPECIAL_KEYS = %i[_id _rev]

    def property *opts, class_name: nil, default: nil
      opts.each do |opt|
        properties << (prop = Property.new(opt, class_name, default))

        silence_redefinition_of_method(opt.to_sym)
        silence_redefinition_of_method(:"#{opt}=")
        silence_redefinition_of_method(:"#{opt}?") if prop.boolean?
        silence_redefinition_of_method(:"[]")

        send(:attr_reader, opt)

        define_method(:"#{opt}=") { |value| write_attribute(opt, value) }
        define_method(:"#{opt}?") { send(opt) } if prop.boolean?
        define_method(:"[]") { |name| send(name) }
      end
    end

    def silence_redefinition_of_method(method)
      if method_defined?(method) || private_method_defined?(method)
        # This suppresses the "method redefined" warning; the self-alias
        # looks odd, but means we don't need to generate a unique name
        alias_method method, method
      end
    end

    def properties
      @properties ||= PropertySet.new
    end

    def all_property_keys
      properties.map(&:key) + SPECIAL_KEYS
    end

    def property_keys
      all_property_keys - SPECIAL_KEYS
    end

    def property_clean_doc(doc)
      doc.select { |key, _value| property_keys.include?(key.to_sym) }
    end
  end
end
