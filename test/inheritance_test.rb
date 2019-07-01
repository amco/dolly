require 'test_helper'

class BaseDoc < Dolly::Document
  property :type
end

class BaseBaseDoc < BaseDoc
  property :supertype
end

class NewBar < BaseBaseDoc
  property :a, :b
end

class DocumentTest < Test::Unit::TestCase
  test 'property inheritance' do
    assert_equal(BaseBaseDoc.new.properties.map(&:key), [:supertype, :type])
  end

  test 'deep properties inheritance' do
    assert_equal(NewBar.new.properties.map(&:key), [:a, :b, :supertype, :type])
  end
end
