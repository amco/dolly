module Dolly
  class CouchDocument
    extend Forwardable

    def_delegators :@hash, :[], :+, :<<, :-, :sort, :last, :first, :all, :map, :select, :find, :detect, :count, :merge, :merge!

    def initialize col = {}
      @hash = col
    end

    def special_key_names
      %w/_id _rev/
    end

    def []= n, val
      @hash[n] = val
    end

  end
end
