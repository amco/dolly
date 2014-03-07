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
      @doc[n.to_s] = @property_cache[n]
    end

    def write_property prop_name, value
      @property_cache ||= {}

      n = prop_name.to_sym

      if n == :_id
        return write_property :id, value
      end

      @property_cache.delete n

      if @property.has_key? n
        @property[n] = @doc[n.to_s] = value
      else
        raise Dolly::MissingPropertyError.new(n)
      end
    end

  end
end
