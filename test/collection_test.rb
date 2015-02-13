require 'test_helper'

class FooBar < Dolly::Document
  property :foo, :bar
end

class CollectionTest < ActiveSupport::TestCase

  def setup
    @json = '{"total_rows":2,"offset":0,"rows":[{"id":"foo_bar/0","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/0","_rev":"7f66379ac92eb6dfafa50c94bd795122","foo":"Foo B","bar":"Bar B","type":"foo_bar"}},{"id":"foo_bar/1","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/1","_rev":"4d33cea0e55142c9ecc6a81600095469","foo":"Foo A","bar":"Bar A","type":"foo_bar"}}]}'
    @collection = Dolly::Collection.new @json, FooBar
  end

  test 'each returns nil' do
    assert_equal @collection.each { |foo| puts foo }, nil
  end

end
