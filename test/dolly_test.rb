require 'test_helper'

class FooBar < Dolly::Base
  database_name 'test'
  set_design_doc 'test'

  property :foo, :bar
end

class DollyTest < ActiveSupport::TestCase


  def setup
    data     = {foo: 'Foo', bar: 'Bar', type: 'foo_bar'}
    all_docs = [ {foo: 'Foo B', bar: 'Bar B', type: 'foo_bar'},  {foo: 'Foo A', bar: 'Bar A', type: 'foo_bar'}]

    view_resp   = build_view_response [data]
    empty_resp  =  build_view_response []
    @multi_resp = build_view_response all_docs

    build_request ["foo_bar/1"], view_resp
    build_request ["foo_bar/2"], empty_resp
    build_request ["foo_bar/1","foo_bar/2"], @multi_resp
    build_request [], @multi_resp
  end

  test 'find will get a FooBar document' do
    foo = FooBar.find "1"
    assert_equal true, foo.kind_of?(FooBar)
  end

  test 'will have only set properties' do
    foo = FooBar.find "1"
    assert_equal 'Foo', foo.foo
    assert_equal 'Bar', foo.bar
    assert_equal false, foo.respond_to?(:type)
  end

  test 'getting not found document' do
    assert_raise Dolly::ResourceNotFound do
      missing = FooBar.find "2"
    end
  end

  test 'find with multiple ids will return Collection' do
    many = FooBar.find "1", "2"
    assert_equal true, many.kind_of?(Dolly::Collection)
  end

  test 'all will get 2 docs' do
    all = FooBar.all
    assert_equal 2, all.count
  end

  test 'all will get FooBar documents' do
     all = FooBar.all
     all.each{ |d| assert_equal true, d.kind_of?(FooBar) }
  end

  test 'multi response with right data' do
    all = FooBar.all
    ids = @multi_resp[:rows].map{|d| d[:id]}
    foos = @multi_resp[:rows].map{|d| d[:doc][:foo]}
    bars = @multi_resp[:rows].map{|d| d[:doc][:bar]}
    all.each do |d|
      assert foos.include?(d.foo)
    end
  end

  private
  def build_view_response properties
    rows = properties.map.with_index do |v, i|
      {
        id: "foo_bar/#{i}",
        key: "foo_bar",
        value: 1,
        doc: {_id: "foo_bar/#{i}", _rev: SecureRandom.hex}.merge!(v)
      }
    end
    {total_rows: properties.count, offset:0, rows: rows}
  end

  def build_request keys, body, view_name = 'foo_bar'
    base_url = "http://localhost:5984/test/_design/test/_view/foo_bar"
    query = "keys=#{CGI::escape keys.to_s.gsub(' ','')}&" unless keys.blank?
    FakeWeb.register_uri :get, "#{base_url}?#{query.to_s}include_docs=true", body: body.to_json
  end

end
