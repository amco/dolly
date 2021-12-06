require 'forwardable'

module Dolly
  class HeaderRequest
    extend Forwardable

    CONTENT_TYPE_KEY = 'Content-Type'
    JSON_CONTENT = 'application/json'

    def_delegators :@collection, :[], :[]=, :keys, :each, :present?, :merge!, :empty?

    def initialize hash = nil
      @collection = hash || default_value
    end

    def json?
      @collection[CONTENT_TYPE_KEY] == JSON_CONTENT
    end

    private

    def default_value
      { CONTENT_TYPE_KEY => JSON_CONTENT }
    end
  end
end
