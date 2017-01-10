module Dolly
  module Scopes
    extend ActiveSupport::Concern

    included do
      def scope name, options ={ }

      end
    end

    class Scope
      attr_reader :proxy_scope, :proxy_options
      def initialize proxy_scope, options
        @proxy_scope, @proxy_options = proxy_scope, proxy_options
      end
    end
  end
end
