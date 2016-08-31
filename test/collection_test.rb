require 'test_helper'

class BaseDolly < Dolly::Document; end

class FooBar < BaseDolly
  property :foo, :bar
end

class CollectionTest < ActiveSupport::TestCase

  def setup
    @json = '{"total_rows":2,"offset":0,"rows":[{"id":"foo_bar/0","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/0","_rev":"7f66379ac92eb6dfafa50c94bd795122","foo":"Foo B","bar":"Bar B","type":"foo_bar"}},{"id":"foo_bar/1","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/1","_rev":"4d33cea0e55142c9ecc6a81600095469","foo":"Foo A","bar":"Bar A","type":"foo_bar"}}]}'
    @collection = Dolly::Collection.new @json, FooBar
  end

  test 'each returns nil' do
    assert_equal @collection.each { |foo| foo }, nil
  end

  test 'to_a returns an array' do
    assert_equal true, @collection.to_a.is_a?(Array)
  end

  test 'count returns the number of objects in collection' do
    assert_equal 2, @collection.count
  end

  test 'to_json returns a string of json' do
    assert_equal true, @collection.to_json.is_a?(String)
  end

  test 'map returns an enumerator' do
    assert_equal true, @collection.map.is_a?(Enumerator)
  end

  test 'map accepts a block and returns the correct values' do
    assert_equal ["Foo B", "Foo A"], @collection.map(&:foo)
  end

  test 'update attributes will change expected attributes' do
    @collection.update_properties! foo: 'Foo 4 All'
    assert_equal ['Foo 4 All', 'Foo 4 All'], @collection.map(&:foo)
  end

  test 'update empty attributes' do
    json = '{"total_rows":2,"offset":0,"rows":[{"id":"foo_bar/0","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/0","_rev":"7f66379ac92eb6dfafa50c94bd795122","foo":null,"bar":"","type":"foo_bar"}},{"id":"foo_bar/1","key":"foo_bar","value":1,"doc":{"_id":"foo_bar/1","_rev":"4d33cea0e55142c9ecc6a81600095469","foo":"Foo A","bar":"Bar A","type":"foo_bar"}}]}'
    collection = Dolly::Collection.new json, FooBar

    collection.update_properties! foo: 'Foo 4 All', bar: 'stuff'
    assert_equal ['Foo 4 All', 'Foo 4 All'], collection.map(&:foo)
    assert_equal ['stuff', 'stuff'], collection.map(&:bar)
  end

  test 'update attributes will raise exception if property is missing' do
    assert_raise Dolly::MissingPropertyError do
      @collection.update_properties! missing: 'Ha! Ha!'
    end
  end
end
