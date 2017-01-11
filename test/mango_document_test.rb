require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title

  scope :by_year, ->(year) { select('year', :eq, year) }
  scope :by_title, ->(title) { select('title', :eq, title) }
  scope :by_char, ->(char) { select('char', :eq, char) }
end

class MangoDocumentTest < ActiveSupport::TestCase
  test 'responds to the scoped method' do
    assert MangoDoc.respond_to? :by_year
    assert MangoDoc.respond_to? :by_title
  end

  test 'calling the scope builds the select query' do
    expected = {"selector"=>{"year"=>2000}}
    assert_equal expected, MangoDoc.by_year(2000)
  end

  test 'the scopes are chainable' do
    query = MangoDoc.by_title('A').by_year(2000)
    expected = {"selector"=>{"year"=>2000, "title"=>"A"}}
    assert_equal expected, query
  end

  test 'the scopes are chainable2' do
    query = MangoDoc.by_title('A').by_year(2000).by_char('B')
    expected = {"selector"=>{"year"=>2000, "title"=>"A"}}
    assert_equal expected, query
  end
end
