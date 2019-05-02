module Dolly
  module Configuration
    def env
      @env ||= configuration[db]
    end

    def base_uri
      "#{protocol}#{host}#{port}"
    end

    def protocol
      env[:protocol]
    end

    def host
      env[:host]
    end

    def port
      return unless env[:port]
      ":#{env[:port]}"
    end

    def db_name
      env[:name]
    end

    def configuration
      { default: { host: 'http://localhost', port: '5984', name: 'bs', user: 'root', password: '123' } }
    end
  end
end
