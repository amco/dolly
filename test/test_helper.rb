require 'test/unit'
require 'webmock/test_unit'
require 'mocha/test_unit'
require 'securerandom'

# Load gem files
Dir["#{File.dirname(__FILE__)}/../lib/dolly/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/../lib/refinements/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/../dolly.rb"].each { |f| require f }

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class Test::Unit::TestCase
  DEFAULT_DB = 'test'
  DB_BASE_PATH = "http://localhost:5984/test".freeze

  setup :global_setup

  def global_setup
    response = { uuids: [SecureRandom.uuid] }.to_json

    stub_request(:get, %r{http://.*:5984/_uuids.*}).
      to_return(status: 200, body: response, headers: { 'Content-Type': 'application/json'})
  end

  protected

  def base_path
    %r{http://.*:5984/#{DEFAULT_DB}}
  end

  def generic_response rows, count = 1
    {total_rows: count, offset:0, rows: rows}
  end

  def build_view_response properties
    rows = properties.map.with_index do |v, i|
      {
        id: "foo_bar/#{i}",
        key: "foo_bar",
        value: 1,
        doc: {_id: "foo_bar/#{i}", _rev: SecureRandom.hex}.merge!(v)
      }
    end
    generic_response rows, properties.count
  end

  def build_view_collation_response properties
    rows = properties.map.with_index do |v, i|
      id = i.zero? ? "foo_bar/#{i}" : "baz/#{i}"
      {
        id: id,
        key: "foo_bar",
        value: 1,
        doc: {_id: id, _rev: SecureRandom.hex}.merge!(v)
      }
    end
    generic_response rows, properties.count
  end


  def build_request keys, body, view_name = 'foo_bar'
    query = "keys=#{CGI::escape keys.to_s.gsub(' ','')}&" unless keys&.empty?
    stub_request(:get, "#{query_base_path}?#{query.to_s}include_docs=true").
      to_return(body: body.to_json)
  end

  def query_base_path
    "#{DB_BASE_PATH}/_all_docs"
  end

  def build_save_request(obj)
    stub_request(:put, "#{DB_BASE_PATH}/#{CGI.escape(obj.id)}").
      to_return(body: {ok: true, id: obj.id, rev: "FF0000" }.to_json)
  end
end

class BaseDolly < Dolly::Document; end
