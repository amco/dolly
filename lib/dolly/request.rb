require "httparty"
require "dolly/bulk_document"

module Dolly

  class Request
    include HTTParty
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = '5984'

    attr_accessor :database_name, :host, :port, :bulk_document

    def initialize options = {}
      @host = options["host"] || DEFAULT_HOST
      @port = options["port"] || DEFAULT_PORT

      @database_name = options["name"]
      @username      = options["username"]
      @password      = options["password"]

      @bulk_document = Dolly::BulkDocument.new []
      self.class.base_uri "#{protocol}://#{auth_info}#{host}:#{port}"
    end

    def get resource, data = nil
      q = {query: values_to_json(data)} if data
      request :get, resource, q
    end

    def put resource, data
      request :put, resource, {body: data}
    end

    def post resource, data
      request :post, resource, {body: data}
    end

    def delete resource
      request :delete, resource, {}
    end

    def protocol
      @protocol || 'http'
    end

    def uuids opts = {}
      tools("_uuids", opts)["uuids"]
    end

    private
    def tools path, opts = nil
      q = "?#{CGI.unescape(opts.to_query)}" unless opts.blank?
      JSON::parse self.class.get("/#{path}#{q}")
    end

    def auth_info
      return "" unless @username.present?
      "#{@username}:#{@password}@"
    end

    def values_to_json hash
      hash.reduce({}){|h, v| h[v.first] = v.last.to_json; h}
    end

    def full_path resource
      "/#{database_name}/#{resource}"
    end

    def request method, resource, data = nil
      data ||= {}
      headers = { 'Content-Type' => 'application/json' }
      response = self.class.send method, full_path(resource), data.merge(headers: headers)
      if response.code == 404
        raise Dolly::ResourceNotFound
      elsif (500..600).include? response.code
        raise Dolly::ServerError
      else
        response
      end
    end
  end

end
