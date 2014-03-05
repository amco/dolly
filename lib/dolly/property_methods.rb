module Dolly
  module PropertyMethods

    def [] prop_name
      read_property prop_name
    end

    def []= prop_name, prop_value
      write_property prop_name, prop_value
    end

    def read_property prop_name
      n = prop_name.to_sym

      if n == :_id
        return read_property :id
      end

      ( @property_cache ||= {} )[n] ||= @property[n]
    end

    def write_property prop_name, value
      n = prop_name.to_sym

      if n == :_id
        return write_property :id, value
      end

      @property_cache.delete n

      if @property.has_key? n
        @property[n] = value
      else
        # TODO: make this error
        raise Dolly::MissingPropertyError, "can't write unknown property `#{n}'"
      end
    end
  end
end
