module Dolly
  module Representations
    module Tools
      module ClassMethods
        def clean_representables
          self.instance_variable_set("@representable_attrs", nil)
          self.property :rows
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end
