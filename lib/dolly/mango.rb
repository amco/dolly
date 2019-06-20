# frozen_string_literal: true

module Dolly
  module Mango

    SELECTOR_SYMBOL = "$"
    AVAILABLE_SELECTORS = %I[
      lt
      lte
      eq
      ne
      gte
      gt
      exists
      type
      in
      nin
      size
      mod
      regex
    ].freeze

    DESIGN = "_find"

    def find_by(query, opts = {})
      opts.merge!(limit: 1)
      perform_query(build_query(query, opts))[:docs].first
    end

    def where(query, opts = {})
      perform_query(build_query(query, opts))[:docs]
    end

    private

    def perform_query(structured_query)
      connection.post(DESIGN, structured_query)
    end

    def build_query(query, opts)
      {
        "selector" => build_selectors(query)
      }.merge(opts)
    end

    def build_selectors(query)
      query.map do |key, values|
        inner_key = values.keys.first
        inner_value = values.values.first
        next unless AVAILABLE_SELECTORS.include?(inner_key)

        {
          "#{key}" => {
            build_key(inner_key) => inner_value
          }
        }
      end.compact.inject(:merge)
    end

    def build_key(key)
      "#{SELECTOR_SYMBOL}#{key}"
    end
  end
end
