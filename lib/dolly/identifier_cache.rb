module Dolly
  class IdentifierCache
    DEFAULT_LIMIT = 1000

    def initialize db, limit = DEFAULT_LIMIT
      @database = db
      @@cached ||= refresh
    end

    def next
      next_id = @@cached.shift
      if @@cached.empty?
        @@cached = refresh
      end

      next_id
    end

    def refresh
      @database.uuids count: @limit
    end

    def reset
      @@cached = refresh
    end

  end
end
