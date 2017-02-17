require "dolly/version"
require "dolly/document"
require 'dolly/railtie' if defined?(Rails)

module Dolly
  class << self
    attr_writer :logger

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
