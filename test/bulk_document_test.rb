require 'test_helper'

class Doc < Dolly::Document
  property :name
end

class BulkDocumentTest < Test::Unit::TestCase
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
      d.id = "doc/#{SecureRandom.uuid}"
      @doc << d
    end

    res = docs.map{|d| {ok: true, id: d.id, rev: "2-#{SecureRandom.uuid}"} }.to_json

    stub_request(:post, @req).
      to_return(body: res)

    assert_equal docs, @doc.payload[:docs]

    @doc.save

    assert_equal [], @doc.errors
    assert_equal [], @doc.docs
    assert_equal [], @doc.payload[:docs]
  end

  test 'save reconciles when bulk post is ambiguous but docs are committed' do
    docs = 2.times.map { |i| Doc.new(name: "doc-#{i}").tap { |d| d.id = "doc/#{i}" } }
    docs.each { |d| @doc << d }

    connection = @doc.connection
    curl = connection.send(:curl_connection)
    curl.stubs(:perform).with do |method, uri, *_|
      method.to_sym == :post && uri.path.end_with?('/_bulk_docs')
    end.raises(Curl::Err::RecvError)

    curl.reader.stubs(:fetch_documents_by_ids).returns(
      docs.each_with_object({}) do |d, memo|
        memo[d.id] = { id: d.id, doc: d.to_h.merge(_rev: "1-#{d.id}") }
      end
    )

    @doc.save

    assert_equal [], @doc.errors
    assert_equal [], @doc.docs
    docs.each { |d| assert_equal "1-#{d.id}", d.rev }
  end

  test 'save retries only unapplied docs after ambiguous bulk post' do
    committed = Doc.new(name: 'committed').tap { |d| d.id = 'doc/1' }
    pending = Doc.new(name: 'pending').tap { |d| d.id = 'doc/2' }
    @doc << committed
    @doc << pending

    connection = @doc.connection
    curl = connection.send(:curl_connection)
    bulk_attempts = 0
    retry_body = [{ ok: true, id: 'doc/2', rev: '2-doc/2' }]
    pending_payloads = []

    curl.stubs(:perform).with do |method, uri, data, *_|
      next false unless method.to_sym == :post && uri.path.end_with?('/_bulk_docs')

      bulk_attempts += 1
      raise Curl::Err::RecvError if bulk_attempts == 1

      pending_payloads << data
      true
    end.returns(
      stub(
        status: '200',
        body_str: retry_body.to_json,
        header_str: ''
      )
    )

    curl.reader.stubs(:fetch_documents_by_ids).returns(
      'doc/1' => { id: 'doc/1', doc: committed.to_h.merge(_rev: '1-doc/1') },
      'doc/2' => { id: 'doc/2', error: 'not_found' }
    )

    @doc.save

    assert_equal 2, bulk_attempts
    assert_equal 1, pending_payloads.size
    assert_equal ['doc/2'], pending_payloads.first[:docs].map { |d| d[:_id] || d['_id'] }
    assert_equal [], @doc.errors
    assert_equal [], @doc.docs
    assert_equal '1-doc/1', committed.rev
    assert_equal '2-doc/2', pending.rev
  end
end
