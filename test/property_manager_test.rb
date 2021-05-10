require 'test_helper'

class TestDoc < Dolly::Document
  property :name, class_name: String
end

class PropertyManagerTest < Test::Unit::TestCase
  test 'write_attribute with nil value' do
    doc = TestDoc.new(name: 'name')
    assert_equal(doc.name, 'name')
    doc.update_properties(name: nil)
    assert_equal(doc.name, nil)
  end
end
