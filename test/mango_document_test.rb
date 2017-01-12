require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title, :char

  scope :by_year, ->(year) { selector('year', :eq, year) }
  scope :by_title, ->(title) { selector('title', :eq, title) }
  scope :by_char, ->(char) { selector('char', :eq, char) }
end

class MangoDocumentTest < ActiveSupport::TestCase
  test 'responds to the scoped method' do
    assert MangoDoc.respond_to? :by_year
    assert MangoDoc.respond_to? :by_title
  end

  test 'calling the scope builds the select query' do
    expected = Object.new #currently using tests to see the scope composition.
    assert_equal expected, MangoDoc.by_year(2000)
  end

  test 'the scopes are chainable' do
    query = MangoDoc.by_title('A')
                    .by_year(2000)
    expected = Object.new #currently using tests to see the scope composition.
    assert_equal expected, query
  end

  test 'the scopes are chainable2' do
    query = MangoDoc.by_title('A').by_year(2000).by_char('B')
    expected = Object.new #currently using tests to see the scope composition.
    assert_equal expected, query
  end
end
