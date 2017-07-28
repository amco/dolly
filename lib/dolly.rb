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
      @logger ||= logger_options
    end

    private

    def logger_options
      return Rails.logger if config.log.to_sym == :rails
      return Dolly::Logger.new(config) if config.log.to_sym == :dolly
      return log.new if config.log.is_a?(Class)
      ::Logger.new(config.log_path)
    end
  end
end
