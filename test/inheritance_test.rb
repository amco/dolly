require 'test_helper'

class BaseDoc < Dolly::Document
  typed_model
end

class BaseBaseDoc < BaseDoc
  property :supertype
end

class NewBar < BaseBaseDoc
  property :a, :b
end

class InheritanceTest < Test::Unit::TestCase
  test 'property inheritance' do
    assert_equal(BaseBaseDoc.new.properties.map(&:key), [:supertype, :doc_type])
  end

  test 'deep properties inheritance' do
    assert_equal(NewBar.new.properties.map(&:key), [:a, :b, :supertype, :doc_type])
  end
end
