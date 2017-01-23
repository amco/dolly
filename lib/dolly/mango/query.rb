module Dolly
  module Mango
    class Query
      include Dolly::Mango::Selector

      FIELDS_KEY   = 'fields'.freeze
      LIMIT_KEY    = 'limit'.freeze
      SKIP_KEY     = 'skip'.freeze
      SORT_KEY     = 'sort'.freeze

      attr_reader :proxy_class, :query

      def initialize proxy_class
        @proxy_class = proxy_class
        @query = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
        query.compare_by_identity
      end

      def limit value
        query[LIMIT_KEY] = value
      end

      def sort name, operator
        query[SORT_KEY] ||= []
        query[SORT_KEY] << {name => operator}
      end

      def fields *fields
        query[FIELDS_KEY] ||= []
        query[FIELDS_KEY].push *fields
      end

      def skip integer
        query[SKIP_KEY] = integer.to_i
      end
    end
  end
end
