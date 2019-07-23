require 'test_helper'

class TypedDoc < Dolly::Document
  typed_model
end

class UntypedDoc < Dolly::Document
end

class DocumentTypeTest < Test::Unit::TestCase
  test 'typed?' do
    assert_equal(TypedDoc.new.typed?, true)
    assert_equal(UntypedDoc.new.typed?, false)
  end

  test 'typed_model' do
    assert_equal(TypedDoc.new.type, nil)
    assert_equal(UntypedDoc.new.respond_to?(:type), false)
    assert_raise NoMethodError do
      UntypedDoc.new.type
    end
  end

  test 'set_type' do
    assert_equal(TypedDoc.new.set_type, TypedDoc.name_paramitized)
    assert_equal(UntypedDoc.new.set_type, nil)
  end
end
