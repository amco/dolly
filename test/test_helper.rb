# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'fakeweb'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end


class ActiveSupport::TestCase
  DEFAULT_DB = 'test'

  setup :global_setup

  def global_setup
    FakeWeb.allow_net_connect = false

    response = { uuids: [SecureRandom.uuid] }
    FakeWeb.register_uri(:get, %r|http://.*:5984/_uuids.*|, body: response.to_json)
  end

  protected
  def base_path
    %r|http://.*:5984/#{DEFAULT_DB}|
  end

end

