module Dolly
  class Scope
    attr_reader :proxy_scope, :query_object, :scope, :args

    delegate :query, :proxy_class, to: :query_object

    def initialize query_object, scope, args
      @query_object, @scope = query_object, scope
      @args = args

      query_object.instance_exec(*args, &scope)
    end

    def method_missing(method, *args, &block)
      if proxy_class.scopes.include?(method)
        proxy_class.scopes[method].call(query_object, args)
      else
        collection = proxy_class.database.mango query.to_json
        collection.send(method, *args, &block)
      end
    end
  end
end
