module Dolly
  class Scope
    attr_reader :proxy_scope, :scope

    def initialize proxy_scope, scope
      @proxy_scope, @scope = proxy_scope, scope
    end

    def method_missing(method, *args, &block)
      if proxy_scope.scopes.include?(method)
        proxy_scope.scopes[method].call(self)
      else
        proxy_scope.send(method, *args)
      end
    end
  end
end
