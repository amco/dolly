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
    assert_equal(TypedDoc.new.doc_type, nil)
    assert_equal(UntypedDoc.new.respond_to?(:doc_type), false)
    assert_raise NoMethodError do
      UntypedDoc.new.doc_type
    end
  end

  test 'set_type' do
    assert_equal(TypedDoc.new.set_type, TypedDoc.name_paramitized)
    assert_equal(UntypedDoc.new.set_type, nil)
  end

  test 'using prop type' do
    assert_raise Dolly::InvalidProperty do
      class TypedTypeDoc < Dolly::Document
        property :type
      end
    end
  end
end
