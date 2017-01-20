module Dolly
  module Mango
    class QueryValidator

      def initialize operator, value
        @operator, @value = operator, value
      end

      def validate!
        raise Dolly::UnrecognizedOperator.new(operator) unless operator_base_klass::ALL_OPERATORS.include? operator
        return if operator_base_klass::EQUALITY_OPERATORS.include? operator
        raise Dolly::BadQueryArguement.new(operator, 'Boolean') if operator == operator_base_klass::EXISTS_OPERATOR && ![true, false].include?(value)
        raise Dolly::BadQueryArguement.new(operator, operator_base_klass::POSSIBLE_TYPE_VALUES.join(', ')) if operator == operator_base_klass::TYPE_OPERATOR && !operator_base_klass::POSSIBLE_TYPE_VALUES.include?(value)
        raise Dolly::BadQueryArguement.new(operator, Array) if operator_base_klass::ARRAY_OPERATORS.include?(operator) && !value.is_a?(Array)
        raise Dolly::BadQueryArguement.new(operator, Integer) if operator == operator_base_klass::SIZE_OPERATOR && !value.is_a?(Integer)
        raise Dolly::BadQueryArguement.new(operator, '[Divisor, Remainder] Array of Integers') if operator == operator_base_klass::MOD_OPERATOR && value.is_a?(Array) && value.count == 2 && value.all? {|el| el.is_a? Integer }
        raise Dolly::BadQueryArguement.new(operator, String) if operator == operator_base_klass::REGEX_OPERATOR && !value.is_a?(String)
        raise Dolly::BadQueryArguement.new(operator, Array) if operator_base_klass::COMBINATION_OPERATORS.include?(operator) && !value.is_a?(Array)
      end

      private

      attr_reader :operator, :value

      def operator_base_klass
        Dolly::Mango::Selector
      end
    end
  end
end
