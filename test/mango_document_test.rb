require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title

  scope :by_year, ->(year) { select('year', :eq, year) }
  scope :by_title, ->(title) { select('title', :eq, title) }
end

class MangoDocumentTest < ActiveSupport::TestCase
  test 'responds to the scoped method' do
    assert MangoDoc.respond_to? :by_year
  end

  test 'calling the scope builds the select query' do
    expected = {"selector"=>{"year"=>2000}}
    assert_equal expected, MangoDoc.by_year(2000).query
  end

  test 'the scopes are chainable' do
    query = MangoDoc.by_title('A').by_year(2000).query
    expected = {}
    assert_equal expected, query
  end
end
