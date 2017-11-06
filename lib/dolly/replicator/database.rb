require "dolly/request"
require "dolly/db_config"

module Dolly
  module Replicator
    module Database

      def database
        options = {'name' => '_replicator'}
        replicator_env = env.merge options
        Request.new(replicator_env)
      end
    end
  end
end
