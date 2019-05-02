module Dolly
  module Timestamp
    def write_timestamps(is_persisted)
      return unless timestamped?
      write_attribute(:created_at, Time.now) unless is_persisted
      write_attribute(:updated_at, Time.now)
    end

    def timestamped?
      respond_to?(:created_at) || respond_to?(:update_at)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def timestamps!
        property :created_at, :updated_at
      end
    end
  end
end

