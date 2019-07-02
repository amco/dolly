 require 'test_helper'

class Foo < Dolly::Document
end

class ViewQueryTest < Test::Unit::TestCase

  def setup
    all_docs = [ {foo: 'Foo B', bar: 'Bar B', type: 'foo_bar'},  {foo: 'Foo A', bar: 'Bar A', type: 'foo_bar'}]
    @multi_type_resp = build_view_collation_response all_docs

    stub_request(:get, "http://localhost:5984/test/_design/doc/_view/id?include_docs=true").
      to_return(body: @multi_type_resp.to_json)

  end

  test 'raw_view' do
    assert_equal(Foo.raw_view('doc', 'id'), @multi_type_resp)
    assert_equal(Foo.raw_view('doc', 'id')[:rows].any?, true)
    assert_equal(Foo.raw_view('doc', 'id')[:total_rows].nil?, false)
  end

  test 'view_value' do
    expected = @multi_type_resp[:rows].flat_map{|res| res[:value]}
    assert_equal(Foo.view_value('doc', 'id'), expected)
  end
end
