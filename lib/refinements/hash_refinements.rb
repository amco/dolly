module HashRefinements

  refine Hash do
    # File 'lib/github_api/core_ext/hash.rb', line 54

    def deep_keys
      keys = self.keys
      keys.each do |key|
        if self[key].is_a?(Hash)
          keys << self[key].deep_keys.compact.flatten
          next
        end
      end
      keys.flatten
    end
  end
end
