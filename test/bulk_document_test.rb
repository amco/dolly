require 'test_helper'

class Doc < Dolly::Document
  property :name
end

class BulkDocumentTest < ActiveSupport::TestCase

  setup do
    @doc = Dolly::Document.bulk_document
    @req = "http://localhost:5984/test/_bulk_docs"
  end

  teardown do
    @doc.clear
  end

  test 'bulk document intialize with empty payload' do
    assert_equal [], @doc.docs
  end

  test 'adding document to bulk_doc' do
    d = Doc.new
    @doc << d
    assert @doc.docs.include?(d)
  end

  test 'save document will remove docs from payload' do
    docs = 3.times.map{ Doc.new name: "a" }
    docs.each do |d|
      d.doc['_id'] = "foo_bar/#{SecureRandom.uuid}"
      @doc << d
    end

    res = docs.map{|d| {ok: true, id: d.id, rev: "2-#{SecureRandom.uuid}"} }.to_json
    FakeWeb.register_uri :post, @req, body: res

    @doc.save

    assert_equal [], @doc.errors
    assert_equal [], @doc.docs
  end

end
