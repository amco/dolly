require "dolly/simple_replicator"

module Dolly
  class Request < Dolly::Requests::Base
    def replicate! target_db, opts={}
      Dolly::SimpleReplicator.new(self, target_db, opts).replicate!
    end
  end
end
