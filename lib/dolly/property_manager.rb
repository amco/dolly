module Dolly
  module PropertyManager
    def build_property(attributes)
      assign_identity_properties(attributes)
      assign_rev_properties(attributes)

      lambda do |property|
        name = property.key
        next unless doc[name].nil?
        write_attribute(name, attributes[name])
      end
    end

    def update_attribute
      lambda do |(key, value)|
        raise InvalidProperty unless valid_property?(key)
        write_attribute(key, value)
      end
    end

    def write_attribute(key, value)
      casted_value = set_property_value(key, value)
      instance_variable_set(:"@#{key}", casted_value)
      update_doc(key, casted_value)
    end

    def valid_property?(name)
      properties.include?(name.to_sym)
    end

    def update_doc(key, value)
      doc[key] = value
    end

    def properties
      self.class.properties
    end

    def set_property_value(key, value)
      properties[key].cast_value(value)
    end

    def assign_identity_properties(opts = {})
      id_presence = opts[:id] || opts[:_id] || opts['id'] || opts['_id']
      self.id = id_presence if id_presence
    end

    def assign_rev_properties(opts = {})
      rev_presence = opts[:rev] || opts [:_rev] || opts['rev'] || opts['_rev']
      self.rev = rev_presence if rev_presence
    end
  end
end
