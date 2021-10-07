require 'curb'
require 'oj'
require 'cgi'
require 'net/http'
require 'dolly/request_header'
require 'dolly/exceptions'
require 'dolly/configuration'
require 'refinements/string_refinements'
require 'dolly/framework_helper'

module Dolly
  class Connection
    include Dolly::Configuration
    include Dolly::FrameworkHelper
    attr_reader :db, :app_env

    DEFAULT_HEADER = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    SECURE_PROTOCOL = 'https'
    DEFAULT_DATABASE = :default

    using StringRefinements

    def initialize db = DEFAULT_DATABASE, app_env = :development
      @db      = db
      @app_env = app_env
    end

    def get(resource, data = {})
      query = { query: values_to_json(data) } if data
      request :get, resource, query
    end

    def post resource, data
      request :post, resource.cgi_escape, data
    end

    def put resource, data
      request :put, resource.cgi_escape, data
    end

    def delete resource, rev = nil, escape: true
      query = "?rev=#{rev}" if rev
      resource = "#{escape ? resource.cgi_escape : resource}#{query}"
      request :delete, resource
    end

    def view resource, opts
      request :get, resource, query: values_to_json({include_docs: true}.merge!(opts))
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
      db_resource = (resource =~ %r{^/}) ? resource : "/#{db_name}/#{resource}"
      headers     = fetch_headers(data)
      body        = fetch_body(data)
      uri         = URI("#{base_uri}#{db_resource}")

      conn = curl_method_call(method, uri, body) do |curl|
        if env['username'].present?
          curl.http_auth_types = :basic
          curl.username = env['username']
          curl.password = env['password'].to_s
        end

        headers.each { |k, v| curl.headers[k] = v } if headers.present?
      end
      response_format(conn, method)
    end

    private

    def fetch_headers(data)
      return unless data.is_a?(Hash)
      Dolly::HeaderRequest.new(data&.delete(:headers))
    end

    def fetch_body(data)
      return data unless data.is_a?(Hash)

      data&.delete(:headers)
      data&.merge!(data&.delete(:query) || {})
    end

    def curl_method_call(method, uri, data, &block)
      return Curl::Easy.http_head(uri.to_s, &block) if method.to_sym == :head
      return Curl.delete(uri.to_s, &block) if method.to_sym == :delete
      return Curl.send(method, uri, data, &block) if method.to_sym == :get
      Curl.send(method, uri.to_s, data.to_json, &block)
    end

    def response_format(res, method)
      raise Dolly::ResourceNotFound if res.status.to_i == 404
      raise Dolly::ServerError.new(res.status.to_i) if (400..600).include? res.status.to_i
      return res.header_str if method == :head

      data = Oj.load(res.body_str, symbol_keys: true)
      return data unless rails?
      return data.with_indifferent_access if data.is_a?(Hash)
      data
    rescue Oj::ParseError
      res.body_str
    end

    def values_to_json hash
      hash.each_with_object({}) { |(k,v), h| h[k] = v.is_a?(Numeric) ? v : v.to_json }
    end

    def to_query(string)
      string.map { |k, v| "#{k}=#{v}" }.sort * '&'
    end
  end
end
