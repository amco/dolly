require "dolly/version"
require "dolly/document"
require "dolly/configuration"
require 'dolly/railtie' if defined?(Rails)

module Dolly
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def reset!
      @config = Configuration.new
    end

    def log_requests?
      !!config.log_requests
    end

    def logger
      @logger ||= config.logger
    end
  end
end
