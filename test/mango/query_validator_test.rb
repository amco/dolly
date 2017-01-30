require 'test_helper'

class QueryTestDoc < Dolly::Document; end

class QueryValidatorTest < ActiveSupport::TestCase
  setup do
    @query_object = Dolly::Mango::Query.new(QueryTestDoc)
  end

  class UnrecognizedOperatorTest < QueryValidatorTest
    test 'Dolly::UnrecognizedOperator is raised if the operator is unknown' do
      assert_raise Dolly::UnrecognizedOperator do
        @query_object.selector('field', :operator, "value")
      end
    end
  end

  class AcceptedValuesTest < QueryValidatorTest
    test 'nothing is raised if an equality operator is invoked' do
      assert_nothing_raised do
        @query_object.selector('field', :eq, "value")
        @query_object.selector('ne_field', :ne, 1)
        @query_object.selector('gt_field', :gt, ["value"])
        @query_object.selector('gte_field', :gte, 2008)
        @query_object.selector('lt_field', :lt, "value")
        @query_object.selector('lte_field', :lte, {'key'=>'value'})
      end
    end

    test 'nothing is raised if exists operator is invoked with a boolean' do
      assert_nothing_raised do
        @query_object.selector('field', :exists, true)
        @query_object.selector('field', :exists, false)
      end
    end

    test 'nothing is raised if type operator is invoked with null, boolean, number, string, array or and object' do
      assert_nothing_raised do
        @query_object.selector('field', :type, 'null')
        @query_object.selector('field', :type, 'boolean')
        @query_object.selector('field', :type, 'number')
        @query_object.selector('field', :type, 'string')
        @query_object.selector('field', :type, 'array')
        @query_object.selector('field', :type, 'object')
      end
    end

    test 'nothing is raised if an array operator is invoked with the correct values' do
      assert_nothing_raised do
        @query_object.selector('field', :in, ['value'])
        @query_object.selector('field', :nin, ['value'])
        @query_object.selector('field', :size, 1)
      end
    end

    test 'nothing is raised if a misc operator is invoked with the correct values' do
      assert_nothing_raised do
        @query_object.selector('field', :mod, [3,1])
        @query_object.selector('field', :regex, /[a-zA-Z]{1}/.to_s)
      end
    end
  end

  class UnacceptedValuesTest < QueryValidatorTest

  end
end
