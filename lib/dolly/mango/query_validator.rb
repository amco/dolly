module Dolly
  module Mango
    class QueryValidator

      def initialize operator, value
        @operator, @value = operator, value
      end

      def validate!
        raise Dolly::UnrecognizedOperator.new(operator) unless Selector::ALL_OPERATORS.include? operator
        return if Selector::EQUALITY_OPERATORS.include? operator
        raise Dolly::BadQueryArguement.new(operator, 'Boolean') if operator == Selector::EXISTS_OPERATOR && ![true, false].include?(value)
        raise Dolly::BadQueryArguement.new(operator, Selector::POSSIBLE_TYPE_VALUES.join(', ')) if operator == Selector::TYPE_OPERATOR && !Selector::POSSIBLE_TYPE_VALUES.include?(value)
        raise Dolly::BadQueryArguement.new(operator, Array) if Selector::ARRAY_OPERATORS.include?(operator) && !value.is_a?(Array)
        raise Dolly::BadQueryArguement.new(operator, Integer) if operator == Selector::SIZE_OPERATOR && !value.is_a?(Integer)
        raise Dolly::BadQueryArguement.new(operator, '[Divisor, Remainder] Array of Integers') if operator == Selector::MOD_OPERATOR && (!value.is_a?(Array) || value.count != 2 || value.none? {|el| el.is_a? Integer })
        raise Dolly::BadQueryArguement.new(operator, String) if operator == Selector::REGEX_OPERATOR && !value.is_a?(String)
        raise Dolly::BadQueryArguement.new(operator, Array) if Selector::COMBINATION_OPERATORS.include?(operator) && !value.is_a?(Array)
      end

      private
      attr_reader :operator, :value
    end
  end
end
