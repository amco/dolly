module Dolly
  class Configuration
    attr_accessor :log_requests

    def initialize
      @log_requests = false
    end
  end
end
