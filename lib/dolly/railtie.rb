require 'rails'

module Dolly
  class Railtie < Rails::Railtie
    railtie_name :dolly

    rake_tasks do
      load File.join File.dirname(__FILE__), '../tasks/db.rake'
    end
  end
end

