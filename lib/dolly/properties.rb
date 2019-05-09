require 'dolly/property_set'
require  'dolly/property'

module Dolly
  module Properties
    SPECIAL_KEYS = %i[_id _rev]

    def property *opts, class_name: nil, default: nil
      opts.each do |opt|
        properties << (prop = Property.new(opt, class_name, default))
        send(:attr_reader, opt)

        define_method(:"#{opt}=") { |value| write_attribute(opt, value) }
        define_method(:"#{opt}?") { send(opt) } if prop.boolean?
        define_method(:"[]") {|name| send(name) }
      end
    end

    def properties
      @properties ||= PropertySet.new
    end

    def property_keys
      properties.map(&:key) - SPECIAL_KEYS
    end

    def property_clean_doc(doc)
      doc.reject { |key, _value| !property_keys.include?(key) }
    end
  end
end
