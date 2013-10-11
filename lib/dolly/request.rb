require "httparty"

module Dolly

  class Request
    include HTTParty
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = '5984'

    attr_accessor :database_name, :host, :port

    def initialize options = {}
      @host = options[:host] || DEFAULT_HOST
      @port = options[:port] || DEFAULT_PORT
      @database_name = options[:database_name]

      self.class.base_uri "#{protocol}://#{host}:#{port}"
    end

    def get resource, data
      request :get, resource, {query: values_to_json(data)}
    end

    def protocol
      @protocol || 'http'
    end

    private
    def values_to_json hash
      hash.reduce({}){|h, v| h[v.first] = v.last.to_json; h}
    end

    def full_path resource
      "/#{database_name}/#{resource}"
    end

    def request method, resource, data = nil
      self.class.send method, full_path(resource), data
    end
  end

end
