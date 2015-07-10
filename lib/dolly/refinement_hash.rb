module RefinementHash
  refine Hash do
    def [](key)
      super key.to_s
    end

    def []=(key, value)
      super key.to_s ,value
    end
  end
end
