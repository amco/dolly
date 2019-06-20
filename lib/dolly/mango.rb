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
      build_model_from_doc(find_doc_by(query, opts))
    end

    def find_doc_by(query, opts = {})
      opts.merge!(limit: 1)
      perform_query(build_query(query, opts))[:docs].first
    end

    def where(query, opts = {})
      docs_where(query, opts).map do |doc|
        build_model_from_doc(doc)
      end
    end

    def docs_where(query, opts = {})
      perform_query(build_query(query, opts))[:docs]
    end

    private

    def build_model_from_doc(doc)
      self.new(doc.slice(*self.property_keys))
    end

    def perform_query(structured_query)
      connection.post(DESIGN, structured_query)
    end

    def build_query(query, opts)
      {
        "selector" => build_selectors(query)
      }.merge(opts)
    end

    def build_selectors(query)
      query.each_with_object(Hash.new) do |(key, value), hsh|
        inner_key = value.keys.first
        inner_value = value.values.first
        next unless AVAILABLE_SELECTORS.include?(inner_key)
        hsh.merge!({
          "#{key}" => {
            build_key(inner_key) => inner_value
          }
        })
      end
    end

    def build_key(key)
      "#{SELECTOR_SYMBOL}#{key}"
    end
  end
end
