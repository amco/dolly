require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title, :char
  property :visible_to, class_name: Hash, default: Hash.new
  property :default_collection, class_name: Array, default: Array.new
  timestamps!

  scope :by_year, ->(year) { selector('year', :eq, year) }
  scope :by_title, ->(title) { selector('title', :eq, title) }
  scope :by_char, ->(char) { selector('char', :eq, char) }
  scope :recent, -> { selector('created_at', :gt, 1.year.ago.to_s )}
  scope :old, -> { selector('created_at', :lt, 1.year.ago.to_s )}
  scope :by_visible_to_schools, -> (school_id) { selector('visible_to.schools', :eq, school_id) }
  scope :collection_items_greater_than, -> (item) { selector('default_collection', :em, :gt, item)}
end

class MangoDocumentTest < ActiveSupport::TestCase

  class QueryIsBuiltTest < MangoDocumentTest
    test 'responds to the scoped method' do
      MangoDoc.scopes.keys.each do |k|
        assert_respond_to MangoDoc, k
      end
    end

    test 'calling the scope builds the select query' do
      query = MangoDoc.by_year(2000).query.to_json
      expected = {"selector"=>{"year"=>2000}}.to_json

      assert_equal expected, query
    end

    test 'the scopes are chainable' do
      query = MangoDoc.by_title('A').by_year(2000).query.to_json
      expected = {"selector"=>{"title"=>"A", "year"=>2000}}.to_json

      assert_equal expected, query
    end

    test 'the scopes are chainable2' do
      query = MangoDoc.by_title('A').by_year(2000).by_char('B').query.to_json
      expected = {"selector"=>{"title"=>"A", "year"=>2000, "char"=>"B"}}.to_json

      assert_equal expected, query
    end

    test 'greater than selector builds query correctly' do
      query = MangoDoc.by_title('A').recent.query.to_json
      expected = {"selector"=>{"title"=>"A", "created_at"=>{"$gt"=>1.year.ago.to_s}}}.to_json

      assert_equal expected, query
    end

    test 'less than selector builds query correctly' do
      query = MangoDoc.by_title('A').old.query.to_json
      expected = {"selector"=>{"title"=>"A", "created_at"=>{"$lt"=>1.year.ago.to_s}}}.to_json

      assert_equal expected, query
    end

    test 'selector can handle nested json object querys' do
      query = MangoDoc.by_visible_to_schools('some_id').query.to_json
      expected = {"selector"=>{"visible_to.schools"=>"some_id"}}.to_json
      assert_equal expected, query
    end

    test 'selector can handle multiple operators' do
      query = MangoDoc.collection_items_greater_than(1).query.to_json
      expected = {"selector"=>{"default_collection"=>{"$elemMatch"=>{"$gt"=>1}}}}.to_json
      assert_equal expected, query
    end
  end
end
