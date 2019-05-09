module Dolly
  class PropertySet < Set
    def include? key
      keys.include?(key)
    end

    def [](key)
      return detect {|property| property.key == key } if key.is_a?(Symbol)
      super
    end

    private

    def keys
      map(&:key)
    end
  end
end
