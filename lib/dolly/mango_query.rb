module Dolly
  class MangoQuery

    attr_reader :query

    SELECTOR = 'selector'.freeze
    IN_OPERATOR = '$in'.freeze
    GT_OPERATOR = '$gt'.freeze
    LT_OPERATOR = '$lt'.freeze
    FIELDS_KEY = 'fields'.freeze
    SORT_KEY = 'sort'.freeze
    LIMIT_KEY = 'limit'.freeze

    def select_operator_map
      {
        eq:    ->(name, value) { build_equal_selector name, value },
        in:    ->(name, value) { build_inclusion_selector name, value },
        gt:    ->(name, value) { build_greater_than_selector name, value },
        lt:    ->(name, value) { build_less_than_selector name, value },
      }.freeze
    end

    def initialize
      @query = Hash.new
      instance_eval { yield }
    end

    def select name, operator, value
      @query.deep_merge! select_operator_map[operator].call(name, value)
      return self
    end

    def limit value
      @query[LIMIT_KEY] = value
      return self
    end

    def sort name, operator
      @query[SORT_KEY] ||= []
      @query[SORT_KEY] << {name => operator}
      return self
    end

    def fields *fields
      @query[FIELDS_KEY] ||= []
      fields.each { |field| @query[FIELDS_KEY] << field }
      return self
    end

    private

    def build_equal_selector name, value
      {
        SELECTOR =>
        {
          name => value
        }
      }
    end

    def build_inclusion_selector name, value
      {
        SELECTOR =>
        {
          name => {
            IN_OPERATOR => value
          }
        }
      }
    end

    def build_greater_than_selector name, value
      {
        SELECTOR =>
        {
          name => {
            GT_OPERATOR => value
          }
        }
      }
    end

    def build_less_than_selector name, value
      {
        SELECTOR =>
        {
          name => {
            LT_OPERATOR => value
          }
        }
      }
    end
  end
end
