require 'test_helper'

class SlugedDocument < Dolly::Document
  include Dolly::Slugable
  property :name, class_name: String

  set_slug :set_default_id, unless: :persisted?

  def slugable_properties
    %i[name]
  end
end

class SlugableDocumentTest < Test::Unit::TestCase
  test 'default id of slugable document is name' do
    assert_equal SlugedDocument.new(name: "a").id, "sluged_document/a"
  end
end
