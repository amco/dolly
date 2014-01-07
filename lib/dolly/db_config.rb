module Dolly
  module DbConfig
    attr_accessor :config_file

    def parse_config
      @config_data ||= File.read(config_file)
      raise Dolly::InvalidConfigFileError unless @config_data.present?
      YAML::load( ERB.new(@config_data).result )
    end

    def env
      parse_config[Rails.env]
    end

    def config_file
      root = Rails.root || File.expand_path("../../../test/dummy/",  __FILE__)
      File.join(root, 'config', 'couchdb.yml')
    end
  end
end
