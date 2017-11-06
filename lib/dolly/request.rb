require "httparty"
require "dolly/bulk_document"

module Dolly

  class Request
    include HTTParty
    REQUIRED_KEYS = %w/host port name/.freeze

    attr_accessor :database_name, :host, :port, :bulk_document

    def initialize options = {}
      REQUIRED_KEYS.each do |key|
        raise Dolly::MissingRequestConfigSettings.new(key) unless options[key]
      end

      @host          = options["host"]
      @port          = options["port"]
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

    def stats
      request :get, "/#{database_name}"
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

    def attach resource, attachment_name, data, headers = {}
      data = StringIO.new(data) if data.is_a?(String)
      request :put, attachment_path(resource, attachment_name), {body: data, headers: headers}
    end

    def protocol
      @protocol ||= 'http'
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
      headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      headers.merge! data[:headers] if data[:headers]
      response = self.class.send method, resource, data.merge(headers: headers)
      log_request(resource, response.code) if Dolly.log_requests?
      if response.code == 404
        raise Dolly::ResourceNotFound
      elsif (400..600).include? response.code
        raise Dolly::ServerError.new( response )
      else
        response
      end
    end

    private
    def tools path, opts = nil
      data = {}
      q = "?#{CGI.unescape(opts.to_query)}" unless opts.blank?
      data.merge!(basic_auth: auth_info) if auth_info.present?
      self.class.get("/#{path}#{q}", data).parsed_response
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

    def attachment_path resource, attachment_name
      "#{full_path(resource)}/#{attachment_name}"
    end

    def log_request resource, response_code
      log_value = ->(resource, response_code) { "Query: #{resource}, Response Code: #{response_code}" }
      case response_code
      when 200..399
        Dolly.logger.info log_value[resource, response_code]
      when 400..600
        Dolly.logger.warn log_value[resource, response_code]
      end
    end
  end

end
