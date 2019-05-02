module Dolly
  module Property
    def build_property
      lambda do |name, value|
        write_attribute(name, value)
      end
    end

    def write_attribute key, value
      raise 'Invalid Attr' unless valid_property?(key)
      send(:"#{key}=", value) && update_doc(key, value)
    end

    def valid_property?(name)
      puts name.inspect
      self.class.properties.include? name
    end

    def update_doc(key, value)
      doc[key] = value
    end
  end
end
