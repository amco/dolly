module Dolly
  module Request
    def set_db_namespace(name)
      @_db_namespace = name
    end

    def set_app_env(env)
      @app_env = env
    end

    def connection
      @connection ||= Connection.new(db_namespace, app_env)
    end

    def db_namespace
      @_db_namespace ||= :default
    end

    def app_env
      return Rails.env if defined? Rails.env
      @app_env ||= :development
    end
  end
end
