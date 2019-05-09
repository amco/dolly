module Dolly
  module Request
    def set_namespace name
      @namspace = name
    end

    def set_app_env env
      @app_env = env
    end

    def connection
      @connection ||= Connection.new(namespace, app_env)
    end

    def namespace
      @namespace ||= :default
    end

    def app_env
      return Rails.env if defined? Rails.env
      @app_env ||= :development
    end
  end
end
