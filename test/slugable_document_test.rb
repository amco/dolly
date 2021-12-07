require 'test_helper'

class SlugedDocument < Dolly::Document
  include Dolly::Slugable
  property :name, class_name: String
  set_slug :name
end

class MultiSlugedDocument < Dolly::Document
  include Dolly::Slugable
  property :foo, class_name: String
  property :bar, class_name: Integer

  set_slug :foo, :bar
end

class CustomSeparatorSlug < Dolly::Document
  include Dolly::Slugable
  property :a, class_name: Integer
  property :b, class_name: String
  property :c, class_name: String

  set_slug :a, :b, :c, separator: '*'
end

class SlugableDocumentTest < Test::Unit::TestCase
  test 'default id of slugable document is name' do
    assert_equal SlugedDocument.new(name: "a").id, "sluged_document/a"
  end

  test 'bundled slug id' do
    assert_equal MultiSlugedDocument.new(foo: "a", bar: 1).id, "multi_sluged_document/a_1"
  end

  test 'bundled slug id cant be empty' do
    assert_equal MultiSlugedDocument.new(foo: "a").id, "multi_sluged_document/a_"
  end

  test 'custom seperator slug' do
    assert_equal CustomSeparatorSlug.new(a: 1, b: 'x', c: 'c').id, "custom_separator_slug/1*x*c"
  end

  test 'raise missing slug exception' do
    assert_raise(Dolly::MissingSlugableProperties) do
      class MissingSlugDocument < Dolly::Document
        include Dolly::Slugable
        set_slug :foo
      end
    end
  end
end
