require "dolly/requests/base"
require "dolly/db_config"

module Dolly
  module Replication
    module Database

      def database
        options = {'name' => '_replicator'}
        replicator_env = env.merge options
        Request::Base.new(replicator_env)
      end
    end
  end
end
