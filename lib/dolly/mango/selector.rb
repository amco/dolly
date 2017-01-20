module Dolly
  module Mango
    module Selector

      SELECTOR     = 'selector'.freeze
      EQ_OPERATOR  = '$eq'.freeze
      NE_OPERATOR  = '$ne'.freeze
      IN_OPERATOR  = '$in'.freeze
      GT_OPERATOR  = '$gt'.freeze
      LT_OPERATOR  = '$lt'.freeze
      OR_OPERATOR  = '$or'.freeze
      NOT_SELECTOR = '$not'.freeze
      NOR_SELECTOR = '$nor'.freeze
      AND_OPERATOR = '$and'.freeze
      GTE_OPERATOR = '$gte'.freeze
      LTE_OPERATOR = '$lte'.freeze
      EM_OPERATOR  = '$elemMatch'.freeze

      def select_operator_map
        {
          eq:            ->(name, value) { build_equality_selector name, value, EQ_OPERATOR },
          ne:            ->(name, value) { build_equality_selector name, value, NE_OPERATOR },
          in:            ->(name, value) { build_equality_selector name, value, IN_OPERATOR },
          not:           ->(name, value) { build_exclusive_selector name, value, NOT_SELECTOR },
          nor:           ->(name, value) { build_exclusive_selector name, value, NOR_SELECTOR},
          gt:            ->(name, value) { build_equality_selector name, value, GT_OPERATOR },
          gte:           ->(name, value) { build_equality_selector name, value, GTE_OPERATOR},
          lt:            ->(name, value) { build_equality_selector name, value, LT_OPERATOR },
          lte:           ->(name, value) { build_equality_selector name, value, LTE_OPERATOR },
          em:            ->(name, value) { build_equality_selector name, value, EM_OPERATOR },
          [:em, :gt] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, GT_OPERATOR },
          [:em, :gte] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, GTE_OPERATOR },
          [:em, :lt] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, LT_OPERATOR },
          [:em, :lte] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, LTE_OPERATOR },
          [:em, :or] =>  ->(name, value) { build_composite_selector name, value, EM_OPERATOR, OR_OPERATOR },
          [:em, :and] => ->(name, value) { build_composite_selector name, value, EM_OPERATOR, AND_OPERATOR }
        }.freeze
      end

      private

      def build_equality_selector name, value, operator
        @query[SELECTOR][name][operator] = value
      end

      def build_exclusive_selector name, value, operator
        @query[SELECTOR][operator][name] = value
      end

      def build_composite_selector name, value, *operators
        first, second = operators
        @query[SELECTOR][name][first][second] = value
      end
    end
  end
end
