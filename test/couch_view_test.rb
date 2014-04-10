require 'test_helper'
require 'dolly/couch_view'

class CouchViewTest < ActiveSupport::TestCase

  test 'will not save if on saving status' do
    #TODO: maybe move to use threads instead of forks
    #to prevent a dirty view to be written
  end

end
