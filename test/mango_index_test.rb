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

class MangoIndexTest < Test::Unit::TestCase
  DB_BASE_PATH = "http://localhost:5984/test".freeze

  def setup
    stub_request(:get, index_base_path).
      to_return(body: { indexes:[ {
        ddoc: nil,
        name:"_all_docs",
        type:"special",
        def:{ fields:[{ _id:"asc" }] }
      },
      {
        ddoc: "_design/1",
        name:"foo-index-json",
        type:"json",
        def:{ fields:[{ foo:"asc" }] }
      }
    ]}.to_json)
  end

  test '#delete_all' do
    previous_indexes = Dolly::MangoIndex.all

    stub_request(:delete, index_delete_path(previous_indexes.last)).
      to_return(body: { "ok": true }.to_json)

    Dolly::MangoIndex.delete_all

    stub_request(:get, index_base_path).
      to_return(body: { indexes:[ {
        ddoc: nil,
        name:"_all_docs",
        type:"special",
        def:{ fields:[{ _id:"asc" }] }
      }
    ]}.to_json)

    new_indexes = Dolly::MangoIndex.all
    assert_not_equal(new_indexes.length, previous_indexes.length)
    assert_equal(new_indexes.length, 1)
  end

  def index_base_path
    "#{DB_BASE_PATH}/_index"
  end

  def index_delete_path(doc)
    "#{index_base_path}/#{doc[:ddoc]}/json/#{doc[:name]}"
  end
end
