require 'active_support'

module Dolly
  module Timestamps
    extend ActiveSupport::Concern

    included do
      property :created_at, :updated_at, class_name: DateTime

      before_save :set_created_at, :set_updated_at
    end

    private

    def set_created_at
      self.created_at ||= DateTime.now
    end

    def set_updated_at
      self.updated_at = DateTime.now
    end
  end
end
