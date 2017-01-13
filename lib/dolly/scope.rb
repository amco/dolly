module Dolly
  class Scope
    attr_reader :query_object, :scope, :scope_args

    delegate :proxy_class, to: :query_object

    def initialize query_object, scope, scope_args
      @query_object, @scope = query_object, scope
      @scope_args = scope_args
    end

    def not

    end

    def and

    end

    def or

    end

    def query
      evaluate_scope
    end

    def method_missing(method, *args, &block)
      if proxy_class.scopes.include?(method)
        evaluate_scope
        proxy_class.scopes[method].call(query_object, args)
      else
        evaluate_scope
        collection = proxy_class.database.mango query.to_json
        collection.send(method, *args, &block)
      end
    end

    private

    def evaluate_scope
      query_object.instance_exec(*scope_args, &scope)
    end
  end
end
