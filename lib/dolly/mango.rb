# frozen_string_literal: true

module Dolly
  module Mango

    SELECTOR_SYMBOL = '$'

    COMBINATION_OPERATORS = %I[
      and
      or
      not
      nor
      all
      elemMatch
      allMath
    ].freeze

    CONDITION_OPERATORS = %I[
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

    DESIGN = '_find'

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
      return nil if doc.nil?
      self.new(doc.slice(*self.all_property_keys))
    end

    def perform_query(structured_query)
      connection.post(DESIGN, structured_query)
    end

    def build_query(query, opts)
      {
        'selector' => build_selectors(query)
      }.merge(opts)
    end

    def build_selectors(query)
      query.deep_transform_keys do |key|
        if is_operator?(key)
          build_key(key)
        else
          raise InvalidMangoOperatorError unless self.all_property_keys.include?(key)
          key
        end
      end
    end

    def build_key(key)
      "#{SELECTOR_SYMBOL}#{key}"
    end

    def is_operator?(key)
      COMBINATION_OPERATORS.include?(key) || CONDITION_OPERATORS.include?(key)
    end
  end
end
