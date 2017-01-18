require 'test_helper'

class MangoDoc < Dolly::Document
  property :year, :title, :char
  property :visible_to, class_name: Hash, default: Hash.new
  property :default_collection, class_name: Array, default: Array.new
  timestamps!

  mango_scope :by_year, ->(year) { selector('year', :eq, year) }
  mango_scope :by_title, ->(title) { selector('title', :eq, title) }
  mango_scope :by_char, ->(char) { selector('char', :eq, char) }
  mango_scope :recent, -> { selector('created_at', :gt, 1.year.ago.to_s )}
  mango_scope :old, -> { selector('created_at', :lt, 1.year.ago.to_s )}
  mango_scope :by_visible_to_schools, -> (school_id) { selector('visible_to.schools', :eq, school_id) }
  mango_scope :collection_items_greater_than, -> (item) { selector('default_collection', :em, :gt, item)}

  mango_scope :id_greater_than, ->(id=nil) { selector('_id', :gt, id) }
  mango_scope :support_date_greater_than, ->(date) { selector('support_date', :gt, date)}
  mango_scope :generic_elematch_or, ->(field, item) { selector(field, :em, :or, item) }
end

class MangoDocumentTest < ActiveSupport::TestCase

  class QueryIsBuiltTest < MangoDocumentTest
    test 'responds to the scoped method' do
      MangoDoc.mango_scopes.keys.each do |k|
        assert_respond_to MangoDoc, k
      end
    end

    test 'calling the scope builds the select query' do
      value = 2000
      query = MangoDoc.by_year(value).query.to_json
      expected = {"selector"=>{"year"=>{"$eq"=>value}}}.to_json

      assert_equal expected, query
    end

    test 'the scopes are chainable' do
      title_value = 'A'
      year_value = 2000
      query = MangoDoc.by_title(title_value).by_year(year_value).query.to_json
      expected = {"selector"=>{"title"=>{"$eq"=>title_value}, "year"=>{"$eq"=>year_value}}}.to_json

      assert_equal expected, query
    end

    test 'the scopes are chainable2' do
      title_value = 'A'
      year_value = 2000
      char_value = 'B'
      query = MangoDoc.by_title(title_value).by_year(year_value).by_char(char_value).query.to_json
      expected = {"selector"=>{"title"=>{"$eq"=>title_value}, "year"=>{"$eq"=>year_value}, "char"=>{"$eq"=>char_value}}}.to_json

      assert_equal expected, query
    end

    test 'greater than selector builds query correctly' do
      query = MangoDoc.by_title('A').recent.query.to_json
      expected = {"selector"=>{"title"=>{"$eq"=>"A"}, "created_at"=>{"$gt"=>1.year.ago.to_s}}}.to_json

      assert_equal expected, query
    end

    test 'less than selector builds query correctly' do
      query = MangoDoc.by_title('A').old.query.to_json
      expected = {"selector"=>{"title"=>{"$eq"=>"A"}, "created_at"=>{"$lt"=>1.year.ago.to_s}}}.to_json

      assert_equal expected, query
    end

    test 'selector can handle nested json object querys' do
      value = "some_id"
      query = MangoDoc.by_visible_to_schools(value).query.to_json
      expected = {"selector"=>{"visible_to.schools"=>{"$eq"=>value}}}.to_json
      assert_equal expected, query
    end

    test 'selector can handle multiple operators' do
      query = MangoDoc.collection_items_greater_than(1).query.to_json
      expected = {"selector"=>{"default_collection"=>{"$elemMatch"=>{"$gt"=>1}}}}.to_json
      assert_equal expected, query
    end

    test 'complex selector can be built' do
      expected_query = {
        "selector" => {
          "_id" => {
            "$gt" => nil
          },
          "support_type_date" => {
            "$gt" => Date.today.to_s(:db)
          },
          "visible_to.schools" => {
            "$elemMatch" => {
              "$or" => ([] << "")
            }
          },
          "visible_to.countries" => {
            "$elemMatch" => {
              "$or" => ([] << "")
            }
          },
          "visible_to.programs" => {
            "$elemMatch" => {
              "$or" => ([] << "")
            }
          },
          "visible_to.grades" => {
            "$elemMatch" => {
              "$or" => ([] << "")
            }
          }
        }
      }.to_json
      query = MangoDoc
                .id_greater_than(nil)
                .support_date_greater_than(Date.today.to_s(:db))
                .generic_elematch_or('visible_to.schools', [] << "")
                .generic_elematch_or('visible_to.countries', [] << "")
                .generic_elematch_or('visible_to.programs', [] << "")
                .generic_elematch_or('visible_to.grades', [] << "").query.to_json
      assert expected_query, query
    end
  end
end
