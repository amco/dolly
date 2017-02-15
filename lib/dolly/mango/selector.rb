module Dolly
  module Mango
    module Selector

      SELECTOR     = 'selector'.freeze

      # Equality Operators
      EQ_OPERATOR  = '$eq'.freeze
      NE_OPERATOR  = '$ne'.freeze
      GT_OPERATOR  = '$gt'.freeze
      LT_OPERATOR  = '$lt'.freeze
      GTE_OPERATOR = '$gte'.freeze
      LTE_OPERATOR = '$lte'.freeze

      EQUALITY_OPERATORS = [ EQ_OPERATOR, NE_OPERATOR, GT_OPERATOR, LT_OPERATOR, GTE_OPERATOR, LTE_OPERATOR ].freeze

      # Object Operators
      EXISTS_OPERATOR = '$exists'.freeze
      TYPE_OPERATOR   = '$type'.freeze

      OBJECT_OPERATORS = [EXISTS_OPERATOR, TYPE_OPERATOR].freeze

      # Array Operators
      IN_OPERATOR  = '$in'.freeze
      NIN_OPERATOR = '$nin'.freeze
      SIZE_OPERATOR = '$size'.freeze

      ARRAY_OPERATORS = [IN_OPERATOR, NIN_OPERATOR].freeze

      # Miscellaneous Operators
      MOD_OPERATOR   = '$mod'.freeze
      REGEX_OPERATOR = '$regex'.freeze

      MISC_OPERATORS = [MOD_OPERATOR, REGEX_OPERATOR].freeze

      # Combination Operators
      OR_OPERATOR  = '$or'.freeze
      NOT_SELECTOR = '$not'.freeze
      NOR_SELECTOR = '$nor'.freeze
      AND_OPERATOR = '$and'.freeze
      ALL_OPERATOR = '$all'.freeze
      EM_OPERATOR  = '$elemMatch'.freeze

      COMBINATION_OPERATORS = [ OR_OPERATOR, NOT_SELECTOR, NOR_SELECTOR, AND_OPERATOR, ALL_OPERATOR, EM_OPERATOR ].freeze

      POSSIBLE_TYPE_VALUES = %w/null boolean number string array object/.freeze

      ALL_OPERATORS = [ EQUALITY_OPERATORS, OBJECT_OPERATORS, ARRAY_OPERATORS, SIZE_OPERATOR, MISC_OPERATORS, COMBINATION_OPERATORS ].flatten.freeze

      def selector name, *operator, value
        proxy_operator = operator.last
        operator_check! proxy_operator
        operator = operator.count > 1 ? operator : operator.first
        select_operator_map[operator].call(name, value)
      end

      private

      def select_operator_map
        {
          eq:            ->(name, value) { build_equality_selector name, value, EQ_OPERATOR },
          ne:            ->(name, value) { build_equality_selector name, value, NE_OPERATOR },
          gt:            ->(name, value) { build_equality_selector name, value, GT_OPERATOR },
          gte:           ->(name, value) { build_equality_selector name, value, GTE_OPERATOR },
          lt:            ->(name, value) { build_equality_selector name, value, LT_OPERATOR },
          lte:           ->(name, value) { build_equality_selector name, value, LTE_OPERATOR },

          exists:        ->(name, value=true) { build_equality_selector name, value, EXISTS_OPERATOR },
          type:          ->(name, value) { build_equality_selector name, value, TYPE_OPERATOR },

          in:            ->(name, value) { build_equality_selector name, value, IN_OPERATOR },
          nin:           ->(name, value) { build_equality_selector name, value, NIN_OPERATOR },
          size:          ->(name, value) { build_equality_selector name, value, SIZE_OPERATOR },

          mod:           ->(name, value) { build_equality_selector name, value, MOD_OPERATOR },
          regex:         ->(name, value) { build_equality_selector name, value, REGEX_OPERATOR },

          nor:           ->(name, value) { build_exclusive_selector name, value, NOR_SELECTOR} ,
          all:           ->(name, value) { build_exclusive_selector name, value, ALL_OPERATOR },
          and:           ->(name, value) { build_exclusive_selector name, value, AND_OPERATOR },
          or:            ->(name, value) { build_exclusive_selector name, value, OR_OPERATOR },

          [:em, :gt] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, GT_OPERATOR },
          [:em, :gte] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, GTE_OPERATOR },
          [:em, :lt] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, LT_OPERATOR },
          [:em, :lte] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, LTE_OPERATOR },
          [:em, :or] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, OR_OPERATOR },
          [:em, :and] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, AND_OPERATOR },

          [:not, :gt] =>  ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, GT_OPERATOR },
          [:not, :gte] => ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, GTE_OPERATOR },
          [:not, :lt] =>  ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, LT_OPERATOR },
          [:not, :lte] => ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, LTE_OPERATOR },
          [:not, :or] =>  ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, OR_OPERATOR },
          [:not, :and] => ->(name, value) { build_composite_selector name, value, NOT_OPERATOR, AND_OPERATOR }
        }.freeze
      end

      def build_equality_selector name, value, operator
        operator_value_type_check!(operator, value)
        query[SELECTOR][name][operator] = value
      end

      def build_exclusive_selector name, value, operator
        operator_value_type_check!(operator, value)
        query[SELECTOR][operator][name] = value
      end

      def build_composite_selector name, value, *operators
        first, second = operators
        operator_value_type_check!(second, value)

        query[SELECTOR][name][first][second] = value
      end

      def operator_check! operator
        raise Dolly::UnrecognizedOperator.new(operator) unless select_operator_map.keys.include? operator
      end

      def operator_value_type_check! operator, value
        QueryValidator.new(operator, value).validate!
      end
    end
  end
end
