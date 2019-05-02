module Dolly
  module Request
    def config_namespace name
      @namspace = name
    end

    def connection
      @connection ||= Connection.new(namespace)
    end

    def namespace
      @namespace ||= :default
    end
  end
end
