require "dolly/version"
require "dolly/document"
require "dolly/configuration"
require 'dolly/railtie' if defined?(Rails)

module Dolly
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset!
      @configuration = Configuration.new
    end

    def log_requests?
      !!configuration.log_requests
    end

    def logger
      @logger ||= if defined?(Rails) and Rails.env.development?
        Rails.logger
      else
        Logger.new($stdout).tap do |log|
          log.progname = self.name
        end
      end
    end
  end
end
