module Dolly
  module DbConfig
    attr_accessor :config_file

    def parse_config
      YAML::load( ERB.new( File.read(config_file) ).result)
    end

    def env
      parse_config[Rails.env]
    end

    def auth_info parts
      return "" unless parts['username'].present?
      "#{parts['username']}:#{parts['password']}@"
    end

    def config_file
      root = Rails.root || File.expand_path("../../../test/dummy/",  __FILE__)
      File.join(root, 'config', 'couchdb.yml')
    end
  end
end
