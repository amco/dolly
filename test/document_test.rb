require 'test_helper'

class FooBar < Dolly::Document
  property :foo, :bar
  property :with_default, default: 1
  property :boolean, class_name: TrueClass, default: true

  timestamps!
end

class DocumentTest < ActiveSupport::TestCase
  DB_BASE_PATH = "http://localhost:5984/test/_design/test/_view/".freeze
  VIEW_DOC = "find".freeze

  def setup
    data     = {foo: 'Foo', bar: 'Bar', type: 'foo_bar'}

    all_docs = [ {foo: 'Foo B', bar: 'Bar B', type: 'foo_bar'},  {foo: 'Foo A', bar: 'Bar A', type: 'foo_bar'}]

    view_resp   = build_view_response [data]
    empty_resp  =  build_view_response []
    @multi_resp = build_view_response all_docs

    build_request [["foo_bar","1"]], view_resp
    build_request [["foo_bar","2"]], empty_resp
    build_request [["foo_bar","1"],["foo_bar","2"]], @multi_resp

    FakeWeb.register_uri :get, "#{view_base_path}?startkey=%5B%22foo_bar%22%2Cnull%5D&endkey=%5B%22foo_bar%22%2C%7B%7D%5D&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{view_base_path}?startkey=%5B%22foo_bar%22%2Cnull%5D&endkey=%5B%22foo_bar%22%2C%7B%7D%5D&limit=1&include_docs=true", body: view_resp.to_json
    FakeWeb.register_uri :get, "#{view_base_path}?startkey=%5B%22foo_bar%22%2Cnull%5D&endkey=%5B%22foo_bar%22%2C%7B%7D%5D&limit=2&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{view_base_path}?startkey=%5B%22foo_bar%22%2C%7B%7D%5D&endkey=%5B%22foo_bar%22%2Cnull%5D&limit=1&descending=true&include_docs=true", body: view_resp.to_json
    FakeWeb.register_uri :get, "#{view_base_path}?startkey=%5B%22foo_bar%22%2C%7B%7D%5D&endkey=%5B%22foo_bar%22%2Cnull%5D&limit=2&descending=true&include_docs=true", body: @multi_resp.to_json
  end

  test 'with timestamps!' do
    later = DateTime.new 1963, 1, 1
    now = DateTime.now
    DateTime.stubs(:now).returns(now)
    foo = FooBar.find "1"
    assert_equal now, foo.created_at
    assert_equal now, foo['created_at']
    assert_equal now, foo.updated_at
    assert foo.updated_at = later
    assert_equal later, foo.updated_at
    assert foo['created_at'] = later
    assert_equal later, foo['created_at']
    assert_equal foo['created_at'], foo.created_at
  end

  test 'empty find should raise error' do
    assert_raise Dolly::ResourceNotFound do
      FakeWeb.register_uri :get, "#{view_base_path}?keys=%5B%5D&include_docs=true", :status => ["404", "Not Found"]
      foo = FooBar.find
    end
  end

  test 'error on server raises Dolly::ServerError' do
    assert_raise Dolly::ServerError do
      FakeWeb.register_uri :get, "#{view_base_path}?keys=%5B%5D&include_docs=true", :status => ["500", "Error"]
      foo = FooBar.find
    end
  end

  test 'will have object with boolean? method' do
    foo = FooBar.find "1"
    assert_equal true, foo.boolean?
    foo.boolean = false
    assert_equal false, foo['boolean']
    assert_equal false, foo.boolean?
  end

  test 'find will get a FooBar document' do
    foo = FooBar.find "1"
    assert_equal true, foo.kind_of?(FooBar)
  end

  test 'will have key properties' do
    foo = FooBar.find "1"
    assert_equal 'Foo', foo['foo']
    assert_equal 'Bar', foo['bar']
  end

  test 'will have only set properties' do
    foo = FooBar.find "1"
    assert_equal 'Foo', foo.foo
    assert_equal 'Bar', foo.bar
    assert_equal false, foo.respond_to?(:type)
  end

  test 'with default will return default value on nil' do
    foo = FooBar.find "1"
    assert_equal 1, foo.with_default
  end

  test 'default will be avoerwriten' do
    foo = FooBar.find "1"
    assert_equal 1, foo.with_default
    assert foo.with_default = 30
    assert_equal 30, foo.with_default
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

  test 'all first returns FooBar' do
    first = FooBar.all.first
    assert first.kind_of?(FooBar)
  end

  test 'all last returns FooBar' do
    last = FooBar.all.last
    assert last.kind_of?(FooBar)
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

  test 'first class method returns single item' do
    first = FooBar.first
    assert first.kind_of?(FooBar)
  end

  test 'first class method returns collection' do
    first_2 = FooBar.first 2
    assert first_2.kind_of?(Dolly::Collection)
  end

  test 'last class method returns single item' do
    last = FooBar.last
    assert last.kind_of?(FooBar)
  end

  test 'last class method returns collection' do
    last_2 = FooBar.last 2
    assert last_2.kind_of?(Dolly::Collection)
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
    query = "keys=#{CGI::escape keys.to_s.gsub(' ','')}&" unless keys.blank?
    FakeWeb.register_uri :get, "#{view_base_path}?#{query.to_s}include_docs=true", body: body.to_json
  end

  def view_base_path
    "#{DB_BASE_PATH}#{VIEW_DOC}"
  end

end
