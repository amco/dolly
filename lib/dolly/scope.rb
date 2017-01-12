module Dolly
  class Scope
    attr_reader :proxy_scope, :query_object, :scope

    def initialize proxy_scope, query_object, scope
      @proxy_scope, @query_object, @scope = proxy_scope, query_object, scope
    end

    def method_missing(method, *args, &block)
      if proxy_scope.scopes.include?(method)
        proxy_scope.scopes[method].call(self, query_object)
      else
        proxy_scope.send(method, *args)
      end
    end
  end
end
