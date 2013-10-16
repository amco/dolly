require "dolly/request"

module Dolly
  module Connection

    def database
      @database ||= Request.new(database_name: @@database_name)
    end

    def database_name value
       @@database_name ||= value
    end

  end
end
