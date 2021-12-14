module Dolly
  module FrameworkHelper
    def rails?
      !!defined?(ActiveSupport::HashWithIndifferentAccess)
    end
  end
end
