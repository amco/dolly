require 'dolly/mango/selector'
module Dolly
  class MangoQuery
    include Dolly::Mango::Selector

    attr_reader :proxy_class, :query

    def initialize proxy_class
      @proxy_class = proxy_class
      @query = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
      @query.compare_by_identity
    end

    def selector name, *operator, value
      operator = operator.count > 1 ? operator : operator.first
      select_operator_map[operator].call(name, value)
    end

    def limit value
      @query[LIMIT_KEY] = value
    end

    def sort name, operator
      @query[SORT_KEY] ||= []
      @query[SORT_KEY] << {name => operator}
    end

    def fields *fields
      @query[FIELDS_KEY] ||= []
      @query[FIELDS_KEY].push *fields
    end
  end
end
