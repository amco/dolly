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
      self.class.base_uri "#{protocol}://#{host}:#{port}"
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

    def all_docs keys = []
      data = values_to_json({keys: keys.map{|k| k.join('/')} })
      request :get, '_all_docs', {query: data}
    end

    private
    def tools path, opts = nil
      data = {}
      q = "?#{CGI.unescape(opts.to_query)}" unless opts.blank?
      data.merge!(basic_auth: auth_info) if auth_info.present?
      JSON::parse self.class.get("/#{path}#{q}", data)
    end

    def auth_info
      return nil unless @username.present?
      {username: @username, password: @password}
    end

    def values_to_json hash
      hash.reduce({}){|h, v| h[v.first] = v.last.to_json; h}
    end

    def full_path resource
      "/#{database_name}/#{resource}"
    end

    def request method, resource, data = nil
      data ||= {}
      data.merge!(basic_auth: auth_info) if auth_info.present?
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
