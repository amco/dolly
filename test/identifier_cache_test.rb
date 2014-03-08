require 'test_helper'
require 'dolly/identifier_cache'

class IdentifierCacheTest < ActiveSupport::TestCase

  def setup
    db = Dolly::Document.database
    @id_cache = Dolly::IdentifierCache.new db
    @max_limit = 10
  end

  test 'next will present a valid uuid' do
    assert @id_cache.next =~ %r{\h+}
  end

  test 'refresh gets called, after exhausting the number of uuids' do
    expected_uuids = @max_limit/2
    @id_cache.reset
    expected_uuids.times{ @id_cache.next }
    assert_equal expected_uuids, Dolly::IdentifierCache.class_variable_get("@@cached").count
    expected_uuids.times{ @id_cache.next }
    assert_equal @max_limit, Dolly::IdentifierCache.class_variable_get("@@cached").count
  end

  test 'refresh will get set of max limit uuids' do
    assert_equal @max_limit, @id_cache.refresh.count
  end

end
