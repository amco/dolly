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
end

class BaseDolly < Dolly::Document; end
