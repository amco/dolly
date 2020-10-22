require "dolly/bulk_document"

module Dolly

  class Request
    REQUIRED_KEYS = %w/host port name/.freeze
    DollyResponse = Struct.new(:parsed_response, :code) do
      def to_str
        parsed_response
      end
    end

    attr_accessor :database_name, :host, :port, :bulk_document

    def self.base_uri(str = nil)
      return @@base_uri unless str
      @@base_uri = str
    end

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
      data.merge!(data&.delete(:query) || {})

      body = data&.delete(:body) || {}
      body = JSON.parse(body) unless body.is_a? Hash
      data.merge!(body || {})

      headers = { 'Content-Type' => 'application/json' }
      headers.merge! data[:headers] if data[:headers]

      conn = curl_method_call(method, resource, data) do |curl|
        if @username.present?
          curl.http_auth_types = :basic
          curl.username = @username
          curl.password = @password.to_s
        end

        headers.each { |k, v| curl.headers[k] = v } if headers.present?
      end

      response = response_format(conn)

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

    def base_uri
      @@base_uri
    end

    def curl_method_call(method, resource, data, &block)
      full_uri = resource.include?('http:') ? resource : "#{base_uri}#{resource}"
      uri = URI(full_uri)
      puts uri.inspect

      return Curl::Easy.http_head(uri.to_s, &block) if method.to_sym == :head
      return Curl.delete(uri.to_s, &block) if method.to_sym == :delete
      return Curl.send(method, uri, data, &block) if method.to_sym == :get
      Curl.send(method, uri.to_s, data.to_json, &block)
    end

    def response_format(res)
      DollyResponse.new res.body_str, res.status.to_i
    end

    def tools path, opts = nil
      data = {}
      q = "?#{CGI.unescape(opts.to_query)}" unless opts.blank?
      data.merge!(basic_auth: auth_info) if auth_info.present?
      JSON::parse request(:get, "/#{path}#{q}", data).parsed_response
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
