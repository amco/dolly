require 'json'
require 'cgi'
require 'net/http'
require 'dolly/request_header'
require 'dolly/exceptions'
require 'dolly/configuration'
require 'refinements/string_refinements'

module Dolly
  class Connection
    include Dolly::Configuration
    attr_reader :db

    DEFAULT_HEADER = { 'Content-Type' => 'application/json' }

    using StringRefinements

    def initialize db = :default
      @db = db
    end

    def get(resource, data = {})
      query = { query: values_to_json(data) } if data
      request :get, resource.cgi_escape, query
    end

    def post resource, data
      request :post, resource.cgi_escape, data
    end

    def put resource, data
      request :put, resource.cgi_escape, data
    end

    def delete resource, rev
      request :delete, resource.cgi_escape, query: { rev: rev }
    end

    def view resource, opts
      request :get, resource, query: values_to_json(opts)
    end

    def attach resource, attachment_name, data, headers = {}
      request :put, "#{resource.cgi_escape}/#{attachment_name}", { _body: data }.merge(headers: headers)
    end

    def uuids opts = {}
      tools("_uuids", opts)[:uuids]
    end

    def stats
      get("/#{db_name}")
    end

    def tools path, opts = nil
      request(:get, "/#{path}", opts)
    end

    def request(method, resource, data = {})
      headers  = Dolly::HeaderRequest.new data.delete(:headers)
      uri      = build_uri(resource, data.delete(:query))
      klass    = request_method(method)
      req      = klass.new(uri, headers)
      req.body = format_data(data, headers.json?)
      response = start_request(req)

      response_format(response)
    end

    private

    def start_request(req)
      Net::HTTP.start(req.uri.hostname, req.uri.port) do |http|
        req.basic_auth env[:user], env[:password]
        http.request(req)
      end
    end

    def response_format(res)
      raise Dolly::ResourceNotFound if res.code.to_i == 404
      raise Dolly::ServerError.new(res.body) if (400..600).include? res.code.to_i
      JSON.parse(res.body, symbolize_names: true)
    end

    def format_data(data = nil, is_json)
      return unless data
      body = data.delete(:_body) || data
      is_json ? body.to_json : body
    end

    def build_uri(resource, query = nil)
      query_str = "?#{to_query(query)}" if query
      uri = resource =~ %r{^/} ? resource : "/#{db_name}/#{resource}"
      URI("#{base_uri}#{uri}#{query_str}")
    end

    def request_method(method_name)
      Object.const_get("Net::HTTP::#{method_name.capitalize}")
    end

    def values_to_json hash
      hash.reduce({}){|h, v| h[v.first] = v.last.to_json; h}
    end

    def to_query(string)
      string.collect do |key, value|
        "#{key}=#{value}"
      end.sort * '&'
    end
  end
end
