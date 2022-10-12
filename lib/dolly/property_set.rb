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
      return to_a[key] if key.is_a?(Integer)

      detect do |property|
        property.key == key.to_sym
      end
    end

    private

    def keys
      map(&:key)
    end
  end
end
