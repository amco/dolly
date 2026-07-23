# frozen_string_literal: true

require 'test_helper'

class Dolly::Curl::ConnectionTest < Test::Unit::TestCase
  setup do
    clear_thread_local_curl!
    @reader = Object.new
    def @reader.fetch_document(*)
      nil
    end

    def @reader.fetch_documents_by_ids(*)
      {}
    end

    @curl = Dolly::Curl::Connection.new(db_name: 'test', reader: @reader)
  end

  teardown do
    clear_thread_local_curl!
  end

  test 'reuses the same curl handle on a thread' do
    first = @curl.thread_local_handle
    second = @curl.thread_local_handle

    assert_same first, second
  end

  test 'uses separate curl handles per thread' do
    handles = Queue.new

    threads = 2.times.map do
      Thread.new do
        curl = Dolly::Curl::Connection.new(db_name: 'test', reader: stub_everything('reader'))
        handles << curl.thread_local_handle
      ensure
        store = Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY]
        next unless store

        store.each_value { |handle| handle.close rescue nil }
        Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY] = nil
      end
    end
    threads.each(&:join)

    collected = []
    collected << handles.pop until handles.empty?

    assert_equal 2, collected.map(&:object_id).uniq.size
  end

  test 'discard_handle removes and closes the handle' do
    curl_easy = @curl.thread_local_handle
    curl_easy.expects(:close).once

    @curl.discard_handle

    store = Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY]
    assert_nil store[Dolly::Curl::Connection]
  end

  test 'retries once after a stale connection error on get' do
    response = build_curl_response(status: 200, body: '{"ok":true}')

    @curl.stubs(:perform)
      .raises(Curl::Err::GotNothingError)
      .then.returns(response)
    @curl.expects(:discard_handle).once

    result = @curl.request(:get, URI('http://localhost:5984/test/doc'), {})

    assert_equal response, result
  end

  test 'raises after stale connection retries are exhausted on get' do
    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @curl.expects(:discard_handle).twice

    assert_raises(Curl::Err::RecvError) do
      @curl.request(:get, URI('http://localhost:5984/test/doc'), {})
    end
  end

  test 'retries once after SendError on read-only post' do
    response = build_curl_response(status: 200, body: '{"docs":[]}')

    @curl.stubs(:perform)
      .raises(Curl::Err::SendError)
      .then.returns(response)
    @curl.expects(:discard_handle).once

    result = @curl.request(
      :post,
      URI('http://localhost:5984/test/_find'),
      { selector: { type: 'doc' } }
    )

    assert_equal response, result
  end

  test 'retries once after PartialFileError on _all_docs post' do
    response = build_curl_response(status: 200, body: '{"rows":[]}')

    @curl.stubs(:perform)
      .raises(Curl::Err::PartialFileError)
      .then.returns(response)
    @curl.expects(:discard_handle).once

    result = @curl.request(
      :post,
      URI('http://localhost:5984/test/_all_docs'),
      { keys: ['doc/1'] }
    )

    assert_equal response, result
  end

  test 'stale connection retry creates a fresh curl handle' do
    first_handle = @curl.thread_local_handle
    attempts = 0

    @curl.stubs(:perform).with do |*_args|
      attempts += 1
      raise Curl::Err::GotNothingError if attempts == 1

      true
    end.returns(build_curl_response(status: 200, body: '{"ok":true}'))

    @curl.request(:get, URI('http://localhost:5984/test/doc'), {})
    second_handle = @curl.thread_local_handle

    assert_equal 2, attempts
    refute_same first_handle, second_handle
  end

  test 'discard_handle is safe when no handle exists' do
    assert_nil @curl.discard_handle
  end

  test 'discard_handle ignores errors while closing handle' do
    curl_easy = @curl.thread_local_handle
    curl_easy.stubs(:close).raises(StandardError, 'broken handle')

    assert_nil @curl.discard_handle
    assert_nil Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY][Dolly::Curl::Connection]
  end

  test 'shared curl connection instances reuse one handle per thread' do
    other = Dolly::Curl::Connection.new(db_name: 'test', reader: stub_everything('reader'))

    assert_same @curl.thread_local_handle, other.thread_local_handle
  end

  test 'perform raises for unsupported http methods' do
    error = assert_raises(ArgumentError) do
      @curl.send(:perform, :patch, URI('http://localhost:5984/test/doc'), {})
    end

    assert_match(/unsupported HTTP method/, error.message)
  end

  test 'apply_get_query! is a no-op for nil or empty data' do
    curl = Curl::Easy.new
    curl.url = 'http://localhost:5984/test/doc'

    @curl.send(:apply_get_query!, curl, nil)
    assert_equal 'http://localhost:5984/test/doc', curl.url

    @curl.send(:apply_get_query!, curl, {})
    assert_equal 'http://localhost:5984/test/doc', curl.url
  end

  test 'apply_get_query! appends encoded query parameters' do
    curl = Curl::Easy.new
    curl.url = 'http://localhost:5984/test/doc'

    @curl.send(:apply_get_query!, curl, { 'a' => '1', :b => 'two' })

    assert_equal 'http://localhost:5984/test/doc?a=1&b=two', curl.url
  end

  test 'apply_get_query! uses ampersand when url already has query string' do
    curl = Curl::Easy.new
    curl.url = 'http://localhost:5984/test/doc?rev=1'

    @curl.send(:apply_get_query!, curl, { include_docs: true })

    assert_equal 'http://localhost:5984/test/doc?rev=1&include_docs=true', curl.url
  end

  test 'payload_json returns strings unchanged' do
    payload = '{"ok":true}'

    assert_equal payload, @curl.send(:payload_json, payload)
  end

  test 'payload_json encodes hashes as json' do
    assert_equal '{"ok":true}', @curl.send(:payload_json, ok: true)
  end

  test 'put raises AmbiguousWriteError and does not blind retry' do
    put_uri = URI('http://localhost:5984/test/doc%2F1')
    put_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      put_calls += 1 if method.to_sym == :put
      true
    end.raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_document).returns(nil)
    @curl.expects(:discard_handle).at_least_once

    error = assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:put, put_uri, { _id: 'doc/1', _rev: '1-abc', foo: 'bar' })
    end

    assert_equal 1, put_calls
    assert_equal :put, error.method
    assert_equal put_uri, error.uri
    assert_kind_of Curl::Err::RecvError, error.cause
  end

  test 'put reconciles when committed document matches payload' do
    put_uri = URI('http://localhost:5984/test/doc%2F1')
    payload = { _id: 'doc/1', foo: 'bar' }
    stored = { _id: 'doc/1', _rev: '2-new', foo: 'bar' }

    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_document).returns(stored)

    result = @curl.request(:put, put_uri, payload)

    assert_equal({ ok: true, id: 'doc/1', rev: '2-new' }, result)
  end

  test 'put retries once when create never landed' do
    put_uri = URI('http://localhost:5984/test/doc%2F1')
    payload = { _id: 'doc/1', foo: 'bar' }
    response = build_curl_response(status: 201, body: '{"ok":true,"id":"doc/1","rev":"1-abc"}')
    put_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      put_calls += 1 if method.to_sym == :put
      true
    end.raises(Curl::Err::GotNothingError).then.returns(response)
    @reader.stubs(:fetch_document).returns(nil)

    result = @curl.request(:put, put_uri, payload)

    assert_equal response, result
    assert_equal 2, put_calls
  end

  test 'put retries once when source revision is unchanged' do
    put_uri = URI('http://localhost:5984/test/doc%2F1')
    payload = { _id: 'doc/1', _rev: '1-abc', foo: 'baz' }
    stored = { _id: 'doc/1', _rev: '1-abc', foo: 'bar' }
    response = build_curl_response(status: 201, body: '{"ok":true,"id":"doc/1","rev":"2-def"}')
    put_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      put_calls += 1 if method.to_sym == :put
      true
    end.raises(Curl::Err::PartialFileError).then.returns(response)
    @reader.stubs(:fetch_document).returns(stored)

    result = @curl.request(:put, put_uri, payload)

    assert_equal response, result
    assert_equal 2, put_calls
  end

  test 'put raises AmbiguousWriteError when stored content conflicts' do
    put_uri = URI('http://localhost:5984/test/doc%2F1')
    payload = { _id: 'doc/1', _rev: '1-abc', foo: 'bar' }
    stored = { _id: 'doc/1', _rev: '2-other', foo: 'other' }

    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_document).returns(stored)

    assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:put, put_uri, payload)
    end
  end

  test 'attachment put raises AmbiguousWriteError without blind retry' do
    put_uri = URI('http://localhost:5984/test/doc%2F1/attachment.txt')
    put_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      put_calls += 1 if method.to_sym == :put
      true
    end.raises(Curl::Err::RecvError)

    assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:put, put_uri, { _body: 'payload' })
    end

    assert_equal 1, put_calls
  end

  test 'delete reconciles when document is gone' do
    delete_uri = URI('http://localhost:5984/test/doc%2F1?rev=1-abc')

    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_document).returns(nil)

    result = @curl.request(:delete, delete_uri, nil)

    assert_equal({ ok: true, id: 'doc/1' }, result)
  end

  test 'delete retries once when same revision is still present' do
    delete_uri = URI('http://localhost:5984/test/doc%2F1?rev=1-abc')
    stored = { _id: 'doc/1', _rev: '1-abc', foo: 'bar' }
    response = build_curl_response(status: 200, body: '{"ok":true}')
    delete_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      delete_calls += 1 if method.to_sym == :delete
      true
    end.raises(Curl::Err::GotNothingError).then.returns(response)
    @reader.stubs(:fetch_document).returns(stored)

    result = @curl.request(:delete, delete_uri, nil)

    assert_equal response, result
    assert_equal 2, delete_calls
  end

  test 'delete raises AmbiguousWriteError when revision changed' do
    delete_uri = URI('http://localhost:5984/test/doc%2F1?rev=1-abc')
    stored = { _id: 'doc/1', _rev: '2-new', foo: 'bar' }

    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_document).returns(stored)

    assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:delete, delete_uri, nil)
    end
  end

  test 'unknown write post raises AmbiguousWriteError without blind retry' do
    post_uri = URI('http://localhost:5984/test/_index')
    post_calls = 0

    @curl.stubs(:perform).with do |method, *_|
      post_calls += 1 if method.to_sym == :post
      true
    end.raises(Curl::Err::RecvError)

    error = assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:post, post_uri, { name: 'demo', index: { fields: ['_id'] } })
    end

    assert_equal 1, post_calls
    assert_equal :post, error.method
    assert_kind_of Curl::Err::RecvError, error.cause
  end

  test 'bulk docs reconciles when all documents are already committed' do
    bulk_uri = URI('http://localhost:5984/test/_bulk_docs')
    docs = [
      { _id: 'doc/1', name: 'a' },
      { _id: 'doc/2', name: 'b' }
    ]
    post_calls = 0

    @curl.stubs(:perform).with do |method, uri, *_|
      post_calls += 1 if method.to_sym == :post && uri.path.end_with?('/_bulk_docs')
      true
    end.raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_documents_by_ids).returns(
      'doc/1' => { id: 'doc/1', doc: { _id: 'doc/1', _rev: '1-a', name: 'a' } },
      'doc/2' => { id: 'doc/2', doc: { _id: 'doc/2', _rev: '1-b', name: 'b' } }
    )

    result = @curl.request(:post, bulk_uri, { docs: docs })

    assert_equal(
      [
        { ok: true, id: 'doc/1', rev: '1-a' },
        { ok: true, id: 'doc/2', rev: '1-b' }
      ],
      result
    )
    assert_equal 1, post_calls
  end

  test 'bulk docs retries only unapplied documents' do
    bulk_uri = URI('http://localhost:5984/test/_bulk_docs')
    docs = [
      { _id: 'doc/1', name: 'a' },
      { _id: 'doc/2', name: 'b' }
    ]
    pending_payloads = []
    retry_response = build_curl_response(
      status: 200,
      body: '[{"ok":true,"id":"doc/2","rev":"1-b"}]'
    )

    @curl.stubs(:perform).with do |method, uri, data, *_|
      if method.to_sym == :post && uri.path.end_with?('/_bulk_docs')
        pending_payloads << data
        raise Curl::Err::RecvError if pending_payloads.size == 1
      end
      true
    end.returns(retry_response)
    @reader.stubs(:fetch_documents_by_ids).returns(
      'doc/1' => { id: 'doc/1', doc: { _id: 'doc/1', _rev: '1-a', name: 'a' } },
      'doc/2' => { id: 'doc/2', error: 'not_found' }
    )

    result = @curl.request(:post, bulk_uri, { docs: docs })

    assert_equal [{ docs: [{ _id: 'doc/2', name: 'b' }] }], pending_payloads.drop(1)
    assert_equal(
      [
        { ok: true, id: 'doc/1', rev: '1-a' },
        { ok: true, id: 'doc/2', rev: '1-b' }
      ],
      result
    )
  end

  test 'bulk docs raises AmbiguousWriteError on conflicting content' do
    bulk_uri = URI('http://localhost:5984/test/_bulk_docs')
    docs = [{ _id: 'doc/1', name: 'a' }]

    @curl.stubs(:perform).raises(Curl::Err::RecvError)
    @reader.stubs(:fetch_documents_by_ids).returns(
      'doc/1' => { id: 'doc/1', doc: { _id: 'doc/1', _rev: '1-a', name: 'other' } }
    )

    assert_raises(Dolly::AmbiguousWriteError) do
      @curl.request(:post, bulk_uri, { docs: docs })
    end
  end

  private

  def build_curl_response(status:, body:, headers: '')
    stub(status: status.to_s, body_str: body, header_str: headers)
  end

  def clear_thread_local_curl!
    store = Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY]
    return unless store

    store.each_value { |handle| handle.close rescue nil }
    store.clear
    Thread.current[Dolly::Curl::Connection::THREAD_STORE_KEY] = nil
  end
end
