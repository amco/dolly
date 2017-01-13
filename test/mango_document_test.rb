require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title, :char
  timestamps!

  scope :by_year, ->(year) { selector('year', :eq, year) }
  scope :by_title, ->(title) { selector('title', :eq, title) }
  scope :by_char, ->(char) { selector('char', :eq, char) }
  scope :recent, -> { selector('created_at', :gt, 1.year.ago.to_s )}
  scope :old, -> { selector('created_at', :lt, 1.year.ago.to_s )}
end

class MangoDocumentTest < ActiveSupport::TestCase

  class QueryIsBuiltTest < MangoDocumentTest
    test 'responds to the scoped method' do
      assert MangoDoc.respond_to? :by_year
      assert MangoDoc.respond_to? :by_title
    end

    test 'calling the scope builds the select query' do
      query = MangoDoc.by_year(2000).query
      expected = {"selector"=>{"year"=>2000}}

      assert_equal expected, query
    end

    test 'the scopes are chainable' do
      query = MangoDoc.by_title('A').by_year(2000).query
      expected = {"selector"=>{"title"=>"A", "year"=>2000}}

      assert_equal expected, query
    end

    test 'the scopes are chainable2' do
      query = MangoDoc.by_title('A').by_year(2000).by_char('B').query
      expected = {"selector"=>{"title"=>"A", "year"=>2000, "char"=>"B"}}

      assert_equal expected, query
    end

    test 'greater than selector builds query correctly' do
      query = MangoDoc.by_title('A').recent.query
      expected = {"selector"=>{"title"=>"A", "created_at"=>{"$gt"=>1.year.ago.to_s}}}

      assert_equal expected, query
    end

    test 'less than selector builds query correctly' do
      query = MangoDoc.by_title('A').old.query
      expected = {"selector"=>{"title"=>"A", "created_at"=>{"$lt"=>1.year.ago.to_s}}}

      assert_equal expected, query
    end
  end
end
