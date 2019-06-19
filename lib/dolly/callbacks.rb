module Dolly
  module Callbacks
    extend ActiveSupport::Concern

    module ClassMethods
      include ActiveModel::Callbacks
    end

    included do
      include ActiveModel::Validations::Callbacks

      define_model_callbacks :initialize, :find, :touch, :only => :after
      define_model_callbacks :save, :create, :update, :destroy
    end

    def destroy(hard=true)
      run_callbacks(:destroy) { super(hard) }
    end
  end
end
