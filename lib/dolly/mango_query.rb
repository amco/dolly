module Dolly
  class MangoQuery

    attr_reader :query

    SELECT_OPERATOR_MAP = {
      eq: ->(name, value) { build_equal_selector name, value },
      in:    ->(name, value) { build_inclusion_selector name, value },
      gt:    ->(name, value) { build_greater_than_selector name, value },
      lt:    ->(name, value) { build_less_than_selector name, value },
    }.freeze

    def initialize class
      @query = Hash.new
    end

    def select name, operator, value
      @query.deep_merge! SELECT_OPERATOR_MAP[operator].call(name, value)
      return self
    end

    def limit value
      @query["limit"] = value
      return self
    end

    def sort name, operator
      @query["sort"] ||= []
      @query["sort"] << {name => operator}
      return self
    end

    def fields *fields
      @query['fields'] ||= []
      fields.each { |field| @query['fields'] << field }
      return self
    end

    class << self
      def build_equal_selector name, value
        {
          'selector' =>
          {
            name => value
          },
        }
      end

      def build_inclusion_selector name, value
        {
          'selector' =>
          {
            name => {
              "$in" => value
            }
          }
        }
      end

      def build_greater_than_selector name, value
        {
          'selector' =>
          {
            name => {
              "$gt" => value
            }
          }
        }
      end

      def build_less_than_selector name, value
        {
          'selector' =>
          {
            name => {
              "$lt" => value
            }
          }
        }
      end
    end
  end
end
