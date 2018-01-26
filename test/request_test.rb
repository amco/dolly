require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @default_settings = {'host' => 'www.test.com', 'port' => '5894', 'name' => 'database_name'}
  end

  test 'raises error when intialized without a host' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('host')
    end
  end

  test 'raises error when intialized without a name' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('name')
    end
  end

  test 'raises error when intialized without a port' do
    assert_raise Dolly::MissingRequestConfigSettings do
      Dolly::Request.new @default_settings.dup.delete('port')
    end
  end

  class ReplicateTest < RequestTest
    test 'posts a replication request to the replicator database' do
      db = Dolly::Request.new @default_settings
      other_db = Dolly::Request.new @default_settings.merge({'name' => 'database_2'})
      resp = {
        "ok" => true,
        "session_id" => "8fa6f7bfdad58a9aa229d6c482a06012",
        "source_last_seq" => 5,
        "replication_id_version" => 3,
        "history" =>  [
          {
            "session_id" => "8fa6f7bfdad58a9aa229d6c482a06012",
            "start_time" => Date.today.to_s,
            "end_time" => Date.today.to_s,
            "start_last_seq" => 0,
            "end_last_seq" => 5,
            "recorded_seq" => 5,
            "missing_checked" => 4,
            "missing_found" => 0,
            "docs_read" => 0,
            "docs_written" => 0,
            "doc_write_failures" => 0
          }
        ]
      }
      FakeWeb.register_uri :post, "http://localhost:5984/_replicate", body: resp.to_json
      assert db.replicate!(other_db)
    end
  end
end
