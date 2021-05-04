# frozen_string_literal: true

require 'refinements/hash_refinements'

module Dolly
  module Mango
    using HashRefinements

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
      in
      nin
      size
      mod
      regex
    ].freeze

    TYPE_OPERATOR = %I[
      type
      $type
    ]

    ALL_OPERATORS = COMBINATION_OPERATORS + CONDITION_OPERATORS

    DESIGN = '_find'

    def find_by(query, opts = {})
      build_model_from_doc(find_doc_by(query, opts))
    end

    def find_doc_by(query, opts = {})
      opts.merge!(limit: 1)
      response = perform_query(build_query(query, opts))
      print_index_warning(query) if response.fetch(:warning)
      response[:docs].first
    end

    def where(query, opts = {})
      docs_where(query, opts).map do |doc|
        build_model_from_doc(doc)
      end
    end

    def docs_where(query, opts = {})
      response = perform_query(build_query(query, opts))
      print_index_warning(query) if response.fetch(:warning)
      response[:docs]
    end

    private

    def print_index_warning(query)
      message = "Index not found for #{query.inspect}"
      if (defined?(Rails.logger) && Rails&.env&.development?)
        Rails.logger.info(message)
      else
        puts message
      end
    end

    def build_model_from_doc(doc)
      return nil if doc.nil?
      new(doc.slice(*all_property_keys)).tap { |d| d.rev = doc[:_rev] }
    end

    def perform_query(structured_query)
      connection.post(DESIGN, structured_query)
    end

    def build_query(query, opts)
      { 'selector' => build_selectors(query) }.merge(opts)
    end

    def build_selectors(query)
      query.deep_transform_keys do |key|
        next build_key(key) if is_operator?(key)
        next key if is_type_operator?(key)
        raise Dolly::InvalidMangoOperatorError.new(key) unless has_property?(key)
        key
      end
    end

    def build_key(key)
      return key if key.to_s.starts_with?(SELECTOR_SYMBOL)
      "#{SELECTOR_SYMBOL}#{key}"
    end

    def is_operator?(key)
      ALL_OPERATORS.include?(key) || key.to_s.starts_with?(SELECTOR_SYMBOL)
    end

    def fetch_fields(query)
      deep_keys(query).reject do |key|
        is_operator?(key) || is_type_operator?(key)
      end
    end

    def has_property?(key)
      self.all_property_keys.include?(key)
    end

    def is_type_operator?(key)
      TYPE_OPERATOR.include?(key.to_sym)
    end

    def deep_keys(obj)
      case obj
      when Hash then obj.keys + obj.values.flat_map { |v| deep_keys(v) }
      when Array then obj.flat_map { |i| deep_keys(i) }
      else []
      end
    end
  end
end
