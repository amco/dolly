require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test 'configure allows for changes to configuration' do
    assert Dolly.configure { |dolly| dolly.log_requests = true }
    assert_equal true, Dolly.log_requests?
    assert Dolly.reset!
  end
end
