module Dolly
  module Mango
    class Scope
      attr_reader :query_object, :scope, :scope_args

      delegate :proxy_class, :query, to: :query_object

      def initialize query_object, scope, scope_args
        @query_object, @scope, @scope_args = query_object, scope, scope_args
        evaluate_scope
      end

      def method_missing(method, *args, &block)
        if proxy_class.mango_scopes.include?(method)
          proxy_class.mango_scopes[method].call(query_object, args)
        elsif query_object.respond_to? method
          query_object.send(method, *args, &block)
          return self
        else
          resp = proxy_class.database.mango query.to_json
          collection = Dolly::Collection.new(resp.response.body, proxy_class)
          collection.send(method, *args, &block)
        end
      end

      private

      def evaluate_scope
        query_object.instance_exec(*scope_args, &scope)
      end
    end
  end
end
