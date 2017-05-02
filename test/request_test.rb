require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @default_settings = {'host' => 'www.test.com', 'port' => '5894', 'name' => 'database_name'}
  end

  test 'raises error when intialized without a host' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('host')
    end
  end

  test 'raises error when intialized without a name' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('name')
    end
  end

  test 'raises error when intialized without a port' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('port')
    end
  end
end
