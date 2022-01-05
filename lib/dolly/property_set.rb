module Dolly
  class PropertySet < Set
    def include? key
      keys.include?(key)
    end

    def <<(property)
      return if include?(property.key)
      super(property)
    end

    def [](key)
      detect {|property| property.key == key.to_sym }
    end

    private

    def keys
      map(&:key)
    end
  end
end
