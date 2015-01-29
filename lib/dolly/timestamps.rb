require 'active_support/concern'
require 'active_model/callbacks'

module Dolly
  module Timestamps
    extend ActiveSupport::Concern

    def timestamps!
      Dolly::Document.class_eval do
        extend ActiveModel::Callbacks

        define_model_callbacks :save

        property :created_at, :updated_at, class_name: DateTime

        before_save :set_created_at, :set_updated_at

        def set_created_at
          self.created_at ||= DateTime.now
        end

        def set_updated_at
          self.updated_at = DateTime.now
        end
      end
    end
  end
end
