require 'test_helper'

class FooBar < Dolly::Document
  property :foo, :bar
end

class CollectionTest < ActiveSupport::TestCase

  def setup
    @json = '[{"id": "foo_bar/0", "key": "foo_bar", "value": 1, "doc": {"_id": "foo_bar/0", "_rev": "009eb36693218f8de0aea82273e0285b", "foo": "Foo B", "bar": "Bar B", "type": "foo_bar"}},
             {"id": "foo_bar/1", "key": "foo_bar", "value": 1, "doc": {"_id": "foo_bar/1", "_rev": "ed78e55f6a4309b53255313647df9564", "foo": "Foo A", "bar": "Bar A", "type": "foo_bar"}}]'
    @collection = Dolly::Collection.new @json, FooBar
  end

  test 'each returns nil' do
    assert_equal @collection.each { |foo| puts foo }, nil
  end

end
