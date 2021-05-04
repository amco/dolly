# frozen_string_literal: true

module Dolly
  module QueryArguments
    def last_item_in_range
      "\ufff0"
    end

    def default_query_args
      {
        startkey: "#{name_paramitized}/",
        endkey: "#{name_paramitized}/#{last_item_in_range}"
      }
    end

    def descending_query_args
      {
        startkey: default_query_args[:endkey],
        endkey: default_query_args[:startkey],
        descending: true
      }
    end

    def escape_value(value)
      return value                if value.is_a? Numeric
      return escape_values(value) if value.is_a? Array
      return CGI.escape(value)    if value.is_a? String
      value
    end

    def escape_values *values
      values.flatten.map { |value| escape_value(value) }
    end
  end
end
