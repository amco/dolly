module Dolly
  module Timestamps

    def timestamps!
      property :created_at, :updated_at, class_name: Time

      self.timestamps[self.name] = true

      self.class_eval do

        def set_created_at
          doc['created_at'] ||= Time.now
        end

        def set_updated_at
          doc['updated_at'] = Time.now
        end
      end
    end
  end
end
