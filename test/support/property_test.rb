require 'test_helper'

class TestHashDoc < Dolly::Document
  property :roles, class_name: Hash, default: { teacher: {} }
end

class TestIntegerDoc < Dolly::Document
  property :count, class_name: Integer, default: 0
end

class PropertyTest < Test::Unit::TestCase
  test 'With a hash property with a default value' do
    doc = TestHashDoc.new
    assert_equal(doc.roles, { teacher: {} })
  end

  test 'With a hash property with an empty value it sets the default value' do
    doc = TestHashDoc.new(roles: [])
    assert_equal(doc.roles, { teacher: {} })
  end

  test 'With a hash property with a previous non empty value it preserves the value' do
    doc = TestHashDoc.new(roles: { teacher: { 'user/amco@mail.com': {} } })
    assert_equal(doc.roles, { teacher: { 'user/amco@mail.com': {} } })
  end

  test 'With an Integer property with a nil value it sets the default value' do
    doc = TestIntegerDoc.new(count: nil)
    assert_equal(doc.count, 0)
  end

  test 'With an Integer property with a previous non empty value it preserves the value' do
    doc = TestIntegerDoc.new(count: 10)
    assert_equal(doc.count, 10)
  end
end
