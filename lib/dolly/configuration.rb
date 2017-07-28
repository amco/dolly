require 'dolly/logger'

module Dolly
  class Configuration
    attr_accessor :log_requests, :log_path, :log

    def initialize
      @log_requests = false
      @log_path = $stdout
      @log = :dolly
    end
  end
end
