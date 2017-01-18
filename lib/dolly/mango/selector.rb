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
      AND_OPERATOR = '$and'.freeze
      GTE_OPERATOR = '$gte'.freeze
      LTE_OPERATOR = '$lte'.freeze
      EM_OPERATOR  = '$elemMatch'.freeze

      def select_operator_map
        {
          eq:            ->(name, value) { build_equal_selector name, value },
          ne:            ->(name, value) { build_not_equal_selector name, value },
          in:            ->(name, value) { build_inclusion_selector name, value },
          not:           ->(name, value) { build_not_selector name, value },
          gt:            ->(name, value) { build_gt_selector name, value },
          gte:           ->(name, value) { build_gte_selector name, value },
          lt:            ->(name, value) { build_lt_selector name, value },
          lte:           ->(name, value) { build_lte_selector name, value },
          em:            ->(name, value) { build_element_match_selector name, value },
          [:em, :gt] =>  ->(name, value) { build_element_match_gt_selector name, value },
          [:em, :gte] => ->(name, value) { build_element_match_gte_selector name, value },
          [:em, :lt] =>  ->(name, value) { build_element_match_lt_selector name, value },
          [:em, :lte] => ->(name, value) { build_element_match_lte_selector name, value },
          [:em, :or] =>  ->(name, value) { build_element_match_or_selector name, value },
          [:em, :and] => ->(name, value) { build_element_match_and_selector}
        }.freeze
      end

      private

      def build_equal_selector name, value
        @query[SELECTOR][name][EQ_OPERATOR] = value
      end

      def build_not_equal_selector name, value
        @query[SELECTOR][name][NE_OPERATOR] = value
      end

      def build_not_selector name, value
        @query[SELECTOR][NOT_SELECTOR][name] = value
      end

      def build_element_match_selector name, value
        @query[SELECTOR][name][EM_OPERATOR] = value
      end

      def build_element_match_gt_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][GT_OPERATOR] = value
      end

      def build_element_match_gte_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][GTE_OPERATOR] = value
      end

      def build_element_match_lt_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][LT_OPERATOR] = value
      end

      def build_element_match_lte_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][LTE_OPERATOR] = value
      end

      def build_element_match_or_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][OR_OPERATOR] = value
      end

      def build_element_match_and_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][AND_OPERATOR] = value
      end

      def build_inclusion_selector name, value
        @query[SELECTOR][name][IN_OPERATOR] = value
      end

      def build_gt_selector name, value
        @query[SELECTOR][name][GT_OPERATOR] = value
      end

      def build_gte_selector name, value
        @query[SELECTOR][name][GTE_OPERATOR] = value
      end

      def build_lt_selector name, value
        @query[SELECTOR][name][LT_OPERATOR] = value
      end

      def build_lte_selector name, value
        @query[SELECTOR][name][LTE_OPERATOR] = value
      end
    end
  end
end
