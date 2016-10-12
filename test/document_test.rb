require 'test_helper'

class BaseDolly < Dolly::Document; end

class BarFoo < BaseDolly
  property :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :persist
end

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

class Baz < Dolly::Document; end

class FooBaz < Dolly::Document
  property :foo, class_name: Hash, default: {} do |property|
    property.subproperty :bar, class_name: Array, default: []
    property.subproperty :baz, class_name: Hash, default: Hash.new do |sp|
      sp.subproperty :far, class_name: Hash, default: Hash.new
    end
  end

  def add_to_foo key, value
    foo[key] ||= value
    save!
  end
end

class WithTime < Dolly::Document
  property :created_at, default: -> {Time.now}
end

class TestFoo < Dolly::Document
  property :default_test_property, class_name: String, default: 'FOO'
end

class DocumentWithValidMethod < Dolly::Document
  property :foo

  def valid?
    foo.present?
  end
end

class DocWithSameDefaults < Dolly::Document
  property :foo, :bar, class_name: Array, default: []
end

class Bar < FooBar
  property :a, :b
end

class DocumentTest < ActiveSupport::TestCase
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

    #TODO: Mock Dolly::Request to return helper with expected response. request builder can be tested by itself.
    FakeWeb.register_uri :get, "#{query_base_path}?startkey=%22foo_bar%2F%22&endkey=%22foo_bar%2F%EF%BF%B0%22&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?startkey=%22foo_bar%2F%22&endkey=%22foo_bar%2F%EF%BF%B0%22&limit=1&include_docs=true", body: view_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?endkey=%22foo_bar%2F%22&startkey=%22foo_bar%2F%EF%BF%B0%22&limit=1&descending=true&include_docs=true", body: view_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?startkey=%22foo_bar%2F%22&endkey=%22foo_bar%22%2C%7B%7D&limit=2&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?endkey=%22foo_bar%2F%22&startkey=%22foo_bar%2F%EF%BF%B0%22&limit=2&descending=true&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2F1%22%5D&include_docs=true", body: view_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%5D&include_docs=true", body: not_found_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2Ferror%22%5D&include_docs=true", body: 'error', status: ["500", "Error"]
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2F1%22%2C%22foo_bar%2F2%22%5D&include_docs=true", body: @multi_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2F2%22%5D&include_docs=true", body: not_found_resp.to_json
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2Fbig_doc%22%5D&include_docs=true", body: build_view_response([data.merge(other_property: 'other')]).to_json
  end

  test 'new in memory document' do
    #TODO: clean up all the fake request creation
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/foo_bar%2F.+/, body: resp.to_json
    properties = {foo: 1, bar: 2, boolean: false}
    foo = FooBar.new properties
    assert_equal 1, foo.with_default
    foo.save
    properties.each do |k, v|
      assert_equal v, foo[k]
    end
  end

  test 'empty find should raise error' do
    assert_raise Dolly::ResourceNotFound do
      FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%5D&include_docs=true", :status => ["404", "Not Found"]
      foo = FooBar.find
    end
  end

  test 'error on server raises Dolly::ServerError' do
    assert_raise Dolly::ServerError do
      FakeWeb.register_uri :get, "#{query_base_path}?keys=", :status => ["500", "Error"]
      foo = FooBar.find 'error'
    end
  end

  test 'will have object with boolean? method' do
    foo = FooBar.find "1"
    assert_equal true, foo.boolean?
    foo.boolean = false
    assert_equal false, foo['boolean']
    assert_equal false, foo.boolean?
  end

  test 'will have object with Date method' do
    foo = FooBar.find 1
    foo.date = Date.today
    assert_equal true, foo.date.is_a?(Date)
  end

  test 'will have object with Time method' do
    foo = FooBar.find 1
    foo.time = Time.now
    assert_equal true, foo.time.is_a?(Time)
  end

  test 'will have object with DateTime method' do
    foo = FooBar.find 1
    foo.datetime = DateTime.now
    assert_equal true, foo.datetime.is_a?(DateTime)
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

  test 'can find with fixnum id' do
    foo = FooBar.find 1
    assert_equal 'Foo', foo.foo
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

  test 'reload reloads the doc attribute from database' do
    assert foo = FooBar.find('1')
    expected_doc = foo.doc.dup
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2F0%22%5D&include_docs=true", body: build_view_response([expected_doc]).to_json
    assert foo.foo = 1
    assert_not_equal expected_doc, foo.doc
    assert foo.reload
    assert_equal expected_doc, foo.doc
  end

  test 'accessors work as expected after reload' do
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, "http://localhost:5984/test/foo_bar%2F0", body: resp.to_json
    assert foo = FooBar.find('1')
    assert foo.foo = 1
    assert foo.save
    assert expected_doc = foo.doc
    FakeWeb.register_uri :get, "#{query_base_path}?keys=%5B%22foo_bar%2F0%22%5D&include_docs=true", body: build_view_response([expected_doc]).to_json
    assert foo.reload
    assert_equal 1, foo.foo
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

  test 'delete method on document' do
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :delete, /http:\/\/localhost:5984\/test\/foo_bar%2F[^\?]+\?rev=.+/, body: resp.to_json
    doc = FooBar.find "1"
    doc.destroy
  end

  test 'soft delete on document' do
    skip "delete should be able to do soft deletion."
  end

  test 'query custom view' do
    FakeWeb.register_uri :get, "http://localhost:5984/test/_design/test/_view/custom_view?key=1&include_docs=true", body: @multi_resp.to_json
    f = FooBar.find_with "test", "custom_view", key: 1
    assert_equal 2, f.count
    f.each{ |d| assert d.kind_of?(FooBar) }
  end

  test 'query custom view collation' do
    FakeWeb.register_uri :get, "http://localhost:5984/test/_design/test/_view/custom_view?startkey=%5B1%5D&endkey=%5B1%2C%7B%7D%5D&include_docs=true", body: @multi_type_resp.to_json
    f = FooBar.find_with "test", "custom_view", { startkey: [1], endkey: [1, {}]}
    assert_equal 2, f.count
    assert f.first.kind_of?(FooBar)
    assert f.last.kind_of?(Baz)
  end

  test 'new document have id' do
    foo = FooBar.new
    assert_equal 0, (foo.id =~ /^foo_bar\/[abcdef0-9]+/i)
  end

  test 'Dolly::Document have bulk_document instance' do
    assert Dolly::Document.bulk_document.kind_of?(Dolly::BulkDocument)
  end

  test 'new document will have id from _id or id symbols' do
    foo = FooBar.new id: 'a'
    bar = FooBar.new _id: 'b'
    assert_equal "foo_bar/a", foo.id
    assert_equal "foo_bar/b", bar.id
  end

  test 'new document will have id from _id or id strings' do
    foo = FooBar.new 'id' => 'a'
    bar = FooBar.new '_id' => 'b'
    assert_equal "foo_bar/a", foo.id
    assert_equal "foo_bar/b", bar.id
  end

  test 'new document with no id' do
    foo = FooBar.new
    uuid = %r{
      \A
      foo_bar /
      \h{8}    # 8 hex chars
      (?: - \h{4} ){3}  # 3 groups of 4 hex chars (hyphen sep)
      - \h{12}  # 12 hex chars (hyphen sep again)
      \Z
    }x
    assert foo.id.match(uuid)
  end

  test 'update document properties' do
    foo = FooBar.new 'id' => 'a', foo: 'ab', bar: 'ba'
    assert_equal 'ab', foo.foo
    foo.update_properties foo: 'c'
    assert_equal 'c', foo.foo
  end

  test 'update document propertys with bang' do
    foo = FooBar.new 'id' => 'a', foo: 'ab', bar: 'ba'
    foo.expects(:save).once
    foo.update_properties! foo: 'c'
  end

  test 'trying to update invalid property' do
    foo = FooBar.new 'id' => 'a', foo: 'ab', bar: 'ba'
    assert_raise Dolly::InvalidProperty do
      foo.update_properties key_to_success: false
    end
  end

  test 'set updated at' do
    foo = FooBar.new 'id' => 'a', foo: 'ab'
    foo.update_properties! foo: 'c'
    assert_equal Time.now.to_s, foo.updated_at.to_s
  end

  test 'created at is set' do
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/foo_bar%2F.+/, body: resp.to_json
    properties = {foo: 1, bar: 2, boolean: false}
    foo = FooBar.new properties
    foo.save
    assert_equal Time.now.to_s, foo.created_at.to_s
  end

  test 'reader :bar is not calling the writer :bar=' do
    foo = FooBar.new
    foo.bar = 'bar'
    foo.save!
    foo.expects(:bar=).times(0)
    assert_equal 'bar', foo.bar
  end

  test 'persisted? returns true if _rev is present' do
    foo = FooBar.find "1"
    assert_equal foo.persisted?, true
  end

  test 'persisted? returns false if _rev is not present' do
    foo = FooBar.new
    assert_equal foo.persisted?, false
    assert foo.save
    assert_equal foo.persisted?, true
  end

  test 'can save without timestamps' do
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/foo_baz%2F.+/, body: resp.to_json
    foobaz = FooBaz.new foo: {foo: :bar}
    assert foobaz.save!
  end

  test 'property writes work correctly with pipe equals' do
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/foo_baz%2F.+/, body: resp.to_json
    foobaz = FooBaz.new foo: {'foo' => 'bar'}
    foobaz.add_to_foo 'bar', 'bar'
    assert_equal foobaz.foo, {'foo' => 'bar', 'bar' => 'bar'}
  end

  test 'default should populate before save' do
    test_foo = TestFoo.new
    assert_equal 'FOO', test_foo.doc['default_test_property']
  end

  test 'default should be overridden by params' do
    test_foo = TestFoo.new(default_test_property: 'bar')
    assert_equal 'bar', test_foo.doc['default_test_property']
  end

  test 'doc and method and instance var are the same' do
    test_foo = FooBar.new
    test_foo.foo = 'test_value'
    assert_equal 'test_value', test_foo.foo
    assert_equal 'test_value', test_foo.doc['foo']
    assert_equal 'test_value', test_foo.instance_variable_get(:@foo)
  end

  test 'created at is current time' do
    resp = {ok: true, id: "with_time/timed", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/with_time%2F.+/, body: resp.to_json
    test = WithTime.new id: "timed"
    assert test.respond_to?(:created_at)
    assert test.save
    assert test.created_at
  end

  test 'nil default' do
    properties = {foo: nil, is_nil: nil}
    resp = {ok: true, id: "foo_bar/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/foo_bar%2F.+/, body: resp.to_json
    foo = FooBar.new properties
    foo.save
    properties.each do |k, v|
      assert_equal v, foo[k]
    end
  end

  test 'setting on instance value does set it for other instances' do
    foo = FooBar.new
    foo.bar = 'I belong to the foo, not the bar'
    bar = FooBar.new
    assert_not_equal foo.bar, bar.bar
  end

  test 'subclass raises DocumentInvalidError if valid? fails' do
    foo = DocumentWithValidMethod.new
    assert_raise Dolly::DocumentInvalidError do
      foo.save!
    end
  end

  test 'save returns false for invalid document on save' do
    foo = DocumentWithValidMethod.new
    assert_not foo.save
  end

  test 'save succeeds for invalid document if skipping validations' do
    resp = {ok: true, id: "document_with_valid_method/1", rev: "FF0000"}
    FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/document_with_valid_method%2F.+/, body: resp.to_json
    foo = DocumentWithValidMethod.new
    assert foo.save(validate: false)
  end

  test 'default objects are not the same in memory' do
    doc_with_same_default = DocWithSameDefaults.new
    assert_not doc_with_same_default.foo.equal? doc_with_same_default.bar
    doc_with_same_default.foo.push 'foo'
    assert doc_with_same_default.bar == []
  end

  test 'default properties do not update the class default properties' do
    doc = DocWithSameDefaults.new
    assert_equal [], DocWithSameDefaults.properties[:foo].default
    assert doc.foo.push 'foo'
    assert_equal ['foo'], doc.foo
    assert_equal [], DocWithSameDefaults.properties[:foo].default
    assert second_doc = DocWithSameDefaults.new
    assert_equal [], second_doc.foo
  end

  test 'attach_file! will add a standalone attachment to the document' do
    assert save_response = {ok: true, id: "base_dolly/79178957-96ff-40d9-9ecb-217fa35bdea7", rev: "1"}
    assert FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/base_dolly%2F.+/, body: save_response.to_json
    assert doc = BaseDolly.new
    assert doc.save
    assert resp = {ok: true, id: '79178957-96ff-40d9-9ecb-217fa35bdea7', rev: '2'}
    assert FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/base_dolly\/79178957-96ff-40d9-9ecb-217fa35bdea7\/test.txt/, body: resp.to_json
    assert data = File.open("#{FileUtils.pwd}/test/support/test.txt").read
    assert doc.attach_file! 'test.txt', 'text/plain', data
  end

  test 'attach_file! will add an inline attachment if specified' do
    assert save_response = {ok: true, id: "base_dolly/79178957-96ff-40d9-9ecb-217fa35bdea7", rev: "1"}
    assert FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/base_dolly%2F.+/, body: save_response.to_json
    assert doc = BaseDolly.new
    assert doc.save
    assert resp = {ok: true, id: '79178957-96ff-40d9-9ecb-217fa35bdea7', rev: '2'}
    assert FakeWeb.register_uri :put, /http:\/\/localhost:5984\/test\/base_dolly\/79178957-96ff-40d9-9ecb-217fa35bdea7\/test.txt/, body: resp.to_json
    assert data = File.open("#{FileUtils.pwd}/test/support/test.txt").read
    assert doc.attach_file! 'test.txt', 'text/plain', data, inline: true
    assert doc.doc['_attachments']['test.txt'].present?
    assert_equal Base64.encode64(data), doc.doc['_attachments']['test.txt']['data']
  end

  test "new object from inhereted document" do
    assert bar = Bar.new(a: 1)
    assert_equal 1, bar.a
  end

  test 'subproperties and children subprops are populated on initialize un' do
    instance = FooBaz.new
    expected = {"bar"=>[], "baz"=>{"far"=>{}}}
    assert_equal expected, instance.foo
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
    query = "keys=#{CGI::escape keys.to_s.gsub(' ','')}&" unless keys.blank?
    FakeWeb.register_uri :get, "#{query_base_path}?#{query.to_s}include_docs=true", body: body.to_json
  end

  def query_base_path
    "#{DB_BASE_PATH}/_all_docs"
  end

end
