module Dolly
  module Mango
    module Selector

      SELECTOR     = 'selector'.freeze
      EQ_OPERATOR  = '$eq'
      IN_OPERATOR  = '$in'.freeze
      GT_OPERATOR  = '$gt'.freeze
      LT_OPERATOR  = '$lt'.freeze
      OR_OPERATOR  = '$or'.freeze
      AND_OPERATOR = '$and'.freeze
      EM_OPERATOR  = '$elemMatch'.freeze
      FIELDS_KEY   = 'fields'.freeze
      SORT_KEY     = 'sort'.freeze
      LIMIT_KEY    = 'limit'.freeze

      def select_operator_map
        {
          eq:    ->(name, value) { build_equal_selector name, value },
          in:    ->(name, value) { build_inclusion_selector name, value },
          gt:    ->(name, value) { build_greater_than_selector name, value },
          lt:    ->(name, value) { build_less_than_selector name, value },
          em:    ->(name, value) { build_element_match_selector name, value },
          [:em, :gt] => ->(name, value) { build_element_match_greater_than_selector name, value },
          [:em, :or] => ->(name, value) { build_element_match_or_selector name, value },
          [:em, :and] => ->(name, value) { build_element_match_and_selector}
        }.freeze
      end

      private

      def build_equal_selector name, value
        @query[SELECTOR][name][EQ_OPERATOR] = value
      end

      def build_element_match_selector name, value
        @query[SELECTOR][name][EM_OPERATOR] = value
      end

      def build_element_match_greater_than_selector name, value
        @query[SELECTOR][name][EM_OPERATOR][GT_OPERATOR] = value
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

      def build_greater_than_selector name, value
        @query[SELECTOR][name][GT_OPERATOR] = value
      end

      def build_less_than_selector name, value
        @query[SELECTOR][name][LT_OPERATOR] = value
      end
    end
  end
end
