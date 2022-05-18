require 'test_helper'

class TestDoc < Dolly::Document
  property :name, class_name: String
  property :email, class_name: String
  property :last_name, class_name: String
  property :active, class_name: TrueClass
end

class PropertyManagerTest < Test::Unit::TestCase
  test 'write_attribute with nil value' do
    doc = TestDoc.new(name: 'name', last_name: nil, email: 'does not change', active: 'true')
    assert_equal(doc.name, 'name')
    doc.update_properties(name: nil)
    assert_equal(doc.name, nil)
    assert_equal(doc.last_name, nil)
    assert_equal(doc.email, 'does not change')
    assert_equal(doc.active, true)
  end
end
