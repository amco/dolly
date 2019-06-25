module HashRefinements
  refine Hash do
    # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 82
    def deep_transform_keys(&block)
      _deep_transform_keys_in_object(self, &block)
    end

    def slice(*keys)
      keys.each_with_object(Hash.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end

    private

    def _deep_transform_keys_in_object(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = _deep_transform_keys_in_object(value, &block)
        end
      when Array
        object.map { |e| _deep_transform_keys_in_object(e, &block) }
      else
        object
      end
    end
  end
end
