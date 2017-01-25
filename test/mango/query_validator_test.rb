require 'test_helper'

class QueryTestDoc < Dolly::Document; end

class QueryValidatorTest < ActiveSupport::TestCase
  setup do
    @query_object = Dolly::Mango::Query.new
  end
end
