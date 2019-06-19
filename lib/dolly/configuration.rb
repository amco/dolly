# frozen_string_literal: true

require 'erb'

module Dolly
  module Configuration
    def env
      @env ||= configuration[db.to_s]
    end

    def base_uri
      "#{protocol}#{host}#{port}"
    end

    def protocol
      "#{env['protocol']}://"
    end

    def host
      env['host']
    end

    def port
      return unless env['port']
      ":#{env['port']}"
    end

    def db_name
      env['name']
    end

    def configuration
      @config_data ||= File.read(config_file)
      raise Dolly::InvalidConfigFileError if @config_data&.empty?
      YAML::load(ERB.new(@config_data).result)[app_env.to_s]
    end

    def config_file
      File.join('config', 'couchdb.yml')
    end
  end
end
