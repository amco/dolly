require "httparty"
require "dolly/bulk_document"

module Dolly

  class Request
    include HTTParty
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = '5984'
    ERROR_LEVEL = 400

    attr_accessor :database_name, :host, :port, :bulk_document

    def initialize options = {}
      @host = options["host"] || DEFAULT_HOST
      @port = options["port"] || DEFAULT_PORT

      @database_name = options["name"]
      @username      = options["username"]
      @password      = options["password"]
      @protocol      = options["protocol"]

      @bulk_document = Dolly::BulkDocument.new []
      self.class.base_uri "#{protocol}://#{host}:#{port}"
    end

    def get resource, data = nil
      q = {query: values_to_json(data)} if data
      request :get, full_path(resource), q
    end

    def put resource, data
      request :put, full_path(resource), {body: data}
    end

    def post resource, data
      request :post, full_path(resource), {body: data}
    end

    def delete resource
      request :delete, full_path(resource), {}
    end

    def protocol
      @protocol || 'http'
    end

    def uuids opts = {}
      tools("_uuids", opts)["uuids"]
    end

    def all_docs data = {}
      data =  values_to_json data.merge( include_docs: true )
      request :get, full_path('_all_docs'), {query: data}
    end

    def request method, resource, data = nil
      data ||= {}
      data.merge!(basic_auth: auth_info) if auth_info.present?
      headers = { 'Content-Type' => 'application/json' }
      headers.merge! data[:headers] if data[:headers]
      response = self.class.send method, resource, data.merge(headers: headers)
      raise errors[response.code] if response.code >= ERROR_LEVEL
      response
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

    def errors
      h = {
          400 => Dolly::BadRequest400.new,
          401 => Dolly::Unauthorized401.new,
          403 => Dolly::Forbidden403.new,
          404 => Dolly::NotFound404.new(response),
          405 => Dolly::ResourceNotAllowed405.new,
          406 => Dolly::Unacceptable406.new,
          409 => Dolly::Conflict409.new,
          412 => Dolly::PreconditionFailed412.new,
          415 => Dolly::BadContentType415.new,
          416 => Dolly::RequestedRangeNotSatisfiable416.new,
          417 => Dolly::ExpectationFailed417.new,
          500 => Dolly::InternalServerError5.new
        }
      h.default = "false"
    end
  end
end










