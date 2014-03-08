require "dolly/identifier_cache"

module Dolly
  class CouchDocument
    extend Forwardable

    attr_reader :id_cache

    def_delegators :@hsh, :[]=, :map, :each, :select, :detect, :count, :<<, :+, :-, :|, :merge, :merge!

    def initialize db, options = {}
      @db= db
      @hsh = options
      @id_cache = IdentifierCache.new db
    end

    def [] prop_name
      n = prop_name.to_s

      if n == '_id'
        return @hsh['_id'] ||= id_cache.next
      end

      @hsh[n]
    end

  end
end
