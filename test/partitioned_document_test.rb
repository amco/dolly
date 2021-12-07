require 'test_helper'

class PartitionedDocumentTest < Test::Unit::TestCase
  PARTITIONED_DB_PATH = 'http://localhost:5984/partitioned/'

  test 'unpartitioned DB will raise exception' do
    stub_request(:get, PARTITIONED_DB_PATH).
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 200, body: { db_name: 'partitioned' }.to_json)

    assert_raise(Dolly::PartitionedDataBaseExpectedError) do
      class Partitioned < Dolly::Document
        partitioned!
        property :foo, class_name: String
      end
    end
  end

  test 'document id is partitioned' do
    stub_request(:get, PARTITIONED_DB_PATH).
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 200, body: { db_name: 'partitioned', props: { partitioned: true } }.to_json)

    class Partitioned < Dolly::Document
      set_namespace 'partitioned'
      partitioned!

      property :foo, class_name: String
    end

    doc = Partitioned.new(foo: "something")
    assert doc.id =~ /^partitioned:.+/
  end
end


