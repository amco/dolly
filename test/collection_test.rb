require 'test_helper'

class FooBar < Dolly::Document
  property :foo, :bar
end

class CollectionTest < ActiveSupport::TestCase

  def setup
    @json = '{"rows": {"doc": ["foo", "bar"]}}'
    @collection = Dolly::Collection.new @json, FooBar
  end

  test 'each returns nil' do
    assert_equal @collection.each { |foo| puts foo }, nil
  end

end
