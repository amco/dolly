# frozen_string_literal: true

require 'test_helper'

class ConnectionTest < Test::Unit::TestCase
  setup do
    clear_thread_local_curl!
    @connection = Dolly::Connection.new
  end

  teardown do
    clear_thread_local_curl!
  end

  test 'response_format raises ResourceNotFound for 404 responses' do
    response = build_curl_response(status: 404, body: '{"error":"not_found"}')

    assert_raises(Dolly::ResourceNotFound) do
      @connection.send(:response_format, response, :get)
    end
  end

  test 'response_format raises ServerError for 5xx responses' do
    response = build_curl_response(status: 500, body: '{"error":"internal"}')

    error = assert_raises(Dolly::ServerError) do
      @connection.send(:response_format, response, :get)
    end

    assert_equal 500, error.instance_variable_get(:@msg)
  end

  test 'response_format raises ServerError for 4xx responses' do
    response = build_curl_response(status: 400, body: '{"error":"bad_request"}')

    error = assert_raises(Dolly::ServerError) do
      @connection.send(:response_format, response, :get)
    end

    assert_equal 400, error.instance_variable_get(:@msg)
  end

  test 'response_format returns headers for head responses' do
    response = build_curl_response(status: 200, body: '', headers: "ETag: \"abc\"\r\n")

    assert_equal "ETag: \"abc\"\r\n", @connection.send(:response_format, response, :head)
  end

  test 'response_format returns parsed json for successful responses' do
    response = build_curl_response(status: 200, body: '{"ok":true,"count":2}')

    assert_equal({ ok: true, count: 2 }, @connection.send(:response_format, response, :get))
  end

  test 'response_format returns raw body when json parsing fails' do
    response = build_curl_response(status: 200, body: 'plain text')

    assert_equal 'plain text', @connection.send(:response_format, response, :get)
  end

  test 'request performs get against couchdb with query params' do
    stub_request(:get, 'http://localhost:5984/test/doc/1?rev=1-abc')
      .to_return(status: 200, body: '{"ok":true}', headers: { 'Content-Type' => 'application/json' })

    result = @connection.request(:get, 'doc/1', rev: '1-abc')

    assert_equal({ ok: true }, result)
  end

  test 'request path reuses thread local curl between calls' do
    stub_request(:get, %r{http://localhost:5984/test/_uuids})
      .to_return(status: 200, body: '{"uuids":["abc"]}', headers: { 'Content-Type' => 'application/json' })

    @connection.tools('_uuids')
    first_handle = @connection.send(:curl_connection).thread_local_handle
    @connection.tools('_uuids')
    second_handle = @connection.send(:curl_connection).thread_local_handle

    assert_same first_handle, second_handle
  end

  test 'request performs post against couchdb' do
    stub_request(:post, 'http://localhost:5984/test/_bulk_docs')
      .with(body: '{"docs":[]}')
      .to_return(status: 200, body: '{"ok":true}', headers: { 'Content-Type' => 'application/json' })

    result = @connection.request(:post, '_bulk_docs', docs: [])

    assert_equal({ ok: true }, result)
  end

  test 'request performs put against couchdb' do
    stub_request(:put, 'http://localhost:5984/test/doc%2F1')
      .with(body: '{"foo":"bar"}')
      .to_return(status: 201, body: '{"ok":true,"id":"doc/1","rev":"1-abc"}', headers: { 'Content-Type' => 'application/json' })

    result = @connection.put('doc/1', foo: 'bar')

    assert_equal({ ok: true, id: 'doc/1', rev: '1-abc' }, result)
  end

  test 'request performs delete against couchdb' do
    stub_request(:delete, 'http://localhost:5984/test/doc%2F1?rev=1-abc')
      .to_return(status: 200, body: '{"ok":true}', headers: { 'Content-Type' => 'application/json' })

    result = @connection.delete('doc/1', '1-abc')

    assert_equal({ ok: true }, result)
  end

  test 'request sends custom headers' do
    stub_request(:put, 'http://localhost:5984/test/doc%2F1/attachment.txt')
      .with(headers: { 'Content-Type' => 'text/plain' })
      .to_return(status: 201, body: '{"ok":true}', headers: { 'Content-Type' => 'application/json' })

    result = @connection.attach('doc/1', 'attachment.txt', 'payload', 'Content-Type' => 'text/plain')

    assert_equal({ ok: true }, result)
  end

  test 'curl transport helpers stay outside the public connection api' do
    assert_raises(NoMethodError) { @connection.curl_connection }
    assert_raises(NoMethodError) { @connection.fetch_document('doc/1') }
    assert_raises(NoMethodError) { @connection.fetch_documents_by_ids(['doc/1']) }

    curl = @connection.send(:curl_connection)
    assert_equal 'test', curl.db_name
    assert_instance_of Dolly::Curl::Reader, curl.reader
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
