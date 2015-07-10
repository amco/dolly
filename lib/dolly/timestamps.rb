module Dolly
  module Timestamps

    def timestamps!
      property :created_at, :updated_at, class_name: DateTime

      self.class_variable_set :@@timestamps, true

      Dolly::Document.class_eval do

        def set_created_at
          doc['created_at'] ||= DateTime.now
        end

        def set_updated_at
          doc['updated_at'] = DateTime.now
        end
      end
    end
  end
end
