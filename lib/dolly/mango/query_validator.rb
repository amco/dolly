module Dolly
  module Mango
    class QueryValidator

      def initialize operator, value
        @operator, @value = operator, value
      end

      def validate!
        return if Selector::EQUALITY_OPERATORS.include? operator
        raise Dolly::BadQueryArguement.new(operator, 'Boolean') if boolean_op?
        raise Dolly::BadQueryArguement.new(operator, Selector::POSSIBLE_TYPE_VALUES.join(', ')) if type_op?
        raise Dolly::BadQueryArguement.new(operator, Array) if array_op?
        raise Dolly::BadQueryArguement.new(operator, Integer) if int_op?
        raise Dolly::BadQueryArguement.new(operator, '[Divisor, Remainder] Array of Integers') if mod_op?
        raise Dolly::BadQueryArguement.new(operator, String) if regex_op?
        raise Dolly::BadQueryArguement.new(operator, Array) if combination_op?
      end

      private
      attr_reader :operator, :value

      def boolean_op?
        operator == Selector::EXISTS_OPERATOR && ![true, false].include?(value)
      end

      def type_op?
        operator == Selector::TYPE_OPERATOR && !Selector::POSSIBLE_TYPE_VALUES.include?(value)
      end

      def array_op?
        Selector::ARRAY_OPERATORS.include?(operator) && !value.is_a?(Array)
      end

      def int_op?
        operator == Selector::SIZE_OPERATOR && !value.is_a?(Integer)
      end

      def mod_op?
        operator == Selector::MOD_OPERATOR && (!value.is_a?(Array) || value.count != 2 || value.none? {|el| el.is_a? Integer })
      end

      def regex_op?
        operator == Selector::REGEX_OPERATOR && !value.is_a?(String)
      end

      def combination_op?
        Selector::COMBINATION_OPERATORS.include?(operator) && !value.is_a?(Array)
      end
    end
  end
end
