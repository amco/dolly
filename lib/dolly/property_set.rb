module Dolly
  class PropertySet < Set
    def include?(key)
      keys.include?(key.to_sym)
    end

    def <<(property)
      return if include?(property.key)
      super(property)
    end

    def [](key)
      return detect {|property| property.key == key } if key.is_a?(Symbol)
      detect {|property| property.key.to_s == key }
    end

    private

    def keys
      map(&:key)
    end
  end
end
