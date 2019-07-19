require 'test_helper'

class FooBar < BaseDolly
  property :foo, :bar
  property :with_default, default: 1
  property :boolean, class_name: TrueClass, default: true
  property :date, class_name: Date
  property :time, class_name: Time
  property :datetime, class_name: DateTime
  property :is_nil, class_name: NilClass, default: nil

  timestamps!
end

class MangoTest < Test::Unit::TestCase
  DB_BASE_PATH = "http://localhost:5984/test".freeze

  def setup
    data     = {foo: 'Foo', bar: 'Bar', type: 'foo_bar'}

    all_docs = [ {foo: 'Foo B', bar: 'Bar B', type: 'foo_bar'},  {foo: 'Foo A', bar: 'Bar A', type: 'foo_bar'}]

    view_resp   = build_view_response [data]
    empty_resp  =  build_view_response []
    not_found_resp = generic_response [{ key: "foo_bar/2", error: "not_found" }]
    @multi_resp = build_view_response all_docs
    @multi_type_resp = build_view_collation_response all_docs

    build_request [["foo_bar","1"]], view_resp
    build_request [["foo_bar","2"]], empty_resp
    build_request [["foo_bar","1"],["foo_bar","2"]], @multi_resp

    stub_request(:get, "#{query_base_path}?startkey=%22foo_bar%2F%22&endkey=%22foo_bar%2F%EF%BF%B0%22&include_docs=true").
      to_return(body: @multi_resp.to_json)

    stub_request(:get, "#{all_docs_path}?key=\"index_foo\"").
      to_return(body: {
        total_rows: 2,
        offset: 0,
        rows: [{
          id: '_design/index_foo',
          key: '_design/index_foo',
          value: { rev: '1-c5457a0d26da85f15c4ad6bd739e441d' }
        }]}.to_json)

    stub_request(:get, "#{all_docs_path}?key=\"index_date\"").
      to_return(body: {
        total_rows: 2,
        offset: 0,
        rows: []}.to_json)
  end

  test '#find_by' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.find_by(foo: 'bar').class, FooBar)
  end

  test '#find_by for a property that does not have an index' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_raise Dolly::IndexNotFoundError do
      FooBar.find_by(date: Date.today)
    end
  end

  test '#find_by with no returned data' do
    resp = { docs: [] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.find_by(foo: 'bar'), nil)
  end

  test '#find_doc_by' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.find_doc_by(foo: 'bar').class, Hash)
  end

  test '#where' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.where(foo: { eq: 'bar' }).map(&:class).uniq, [FooBar])
  end

  test '#where for a property that does not have an index' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_raise Dolly::IndexNotFoundError do
      FooBar.where(date: Date.today)
    end
  end

  test '#where with no returned data' do
    resp = { docs: [] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.where(foo: 'bar'), [])
  end

  test '#docs_where' do
    #TODO: clean up all the fake request creation
    resp = { docs: [{ foo: 'bar', id: "foo_bar/1"} ] }

    stub_request(:post, query_base_path).
     to_return(body: resp.to_json)

    assert_equal(FooBar.docs_where(foo: { eq: 'bar' }).map(&:class).uniq, [Hash])
  end

  test '#build_query' do
    query = { and: [{ _id: { eq: 'foo_bar/1' } } , { foo: { eq: 'bar'}} ] }
    opts = {}
    expected = {"selector"=>{"$and"=>[{:_id=>{"$eq"=>"foo_bar/1"}}, {:foo=>{"$eq"=>"bar"}}]}}

    assert_equal(FooBar.send(:build_query, query, opts), expected)
  end

  test '#build_query with options' do
    query = { and: [{ _id: { eq: 'foo_bar/1' } } , { foo: { eq: 'bar'}} ] }
    opts = { limit: 1, fields: ['foo']}
    expected = {"selector"=>{"$and"=>[{:_id=>{"$eq"=>"foo_bar/1"}}, {:foo=>{"$eq"=>"bar"}}]}, limit: 1, fields: ['foo']}

    assert_equal(FooBar.send(:build_query, query, opts), expected)
  end

  test '#build_selectors with invalid operator' do
    query = { _id: { eeeq: 'foo_bar/1' } }

    assert_raise Dolly::InvalidMangoOperatorError do
      FooBar.send(:build_selectors, query)
    end
  end

  private
  def generic_response rows, count = 1
    {total_rows: count, offset:0, rows: rows}
  end

  def build_view_response properties
    rows = properties.map.with_index do |v, i|
      {
        id: "foo_bar/#{i}",
        key: "foo_bar",
        value: 1,
        doc: {_id: "foo_bar/#{i}", _rev: SecureRandom.hex}.merge!(v)
      }
    end
    generic_response rows, properties.count
  end

  def build_view_collation_response properties
    rows = properties.map.with_index do |v, i|
      id = i.zero? ? "foo_bar/#{i}" : "baz/#{i}"
      {
        id: id,
        key: "foo_bar",
        value: 1,
        doc: {_id: id, _rev: SecureRandom.hex}.merge!(v)
      }
    end
    generic_response rows, properties.count
  end


  def build_request keys, body, view_name = 'foo_bar'
    query = "keys=#{CGI::escape keys.to_s.gsub(' ','')}&" unless keys&.empty?
    stub_request(:get, "#{query_base_path}?#{query.to_s}include_docs=true").
      to_return(body: body.to_json)
  end

  def query_base_path
    "#{DB_BASE_PATH}/_find"
  end

  def all_docs_path
    "#{DB_BASE_PATH}/_all_docs"
  end

  def build_save_request(obj)
    stub_request(:put, "#{DB_BASE_PATH}/#{CGI.escape(obj.id)}").
      to_return(body: {ok: true, id: obj.id, rev: "FF0000" }.to_json)
  end
end
