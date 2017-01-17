module Dolly
  class Scope
    attr_reader :query_object, :scope, :scope_args

    delegate :proxy_class, :query, to: :query_object

    def initialize query_object, scope, scope_args
      @query_object, @scope = query_object, scope
      @scope_args = scope_args
      evaluate_scope
    end

    def method_missing(method, *args, &block)
      if proxy_class.mango_scopes.include?(method)
        proxy_class.mango_scopes[method].call(query_object, args)
      else
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
