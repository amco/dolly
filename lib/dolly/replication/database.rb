require "dolly/requests/base"
require "dolly/db_config"

module Dolly
  module Replication
    module Database
      include Dolly::DbConfig

      def database
        options = {'name' => '_replicator'}
        replicator_env = env.merge options
        Requests::Base.new(replicator_env)
      end
    end
  end
end
