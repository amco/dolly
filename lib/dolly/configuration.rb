require 'dolly/logger'
module Dolly
  class Configuration
    attr_accessor :log_requests, :log_path, :log

    def initialize
      @log_requests = false
    end

    def logger
      return Dolly::Logger.new(self) if %i/dolly default/.include?(log)
      Rails.logger if log == :rails
      Dolly::Logger.new self
    end
  end
end
