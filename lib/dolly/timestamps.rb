module Dolly
  module Timestamps

    def timestamps!
      self.class_variable_set :@@timestamps, true

      Dolly::Document.class_eval do
        property :created_at, :updated_at, class_name: DateTime

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
