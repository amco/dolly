require 'dolly/replication/database'

module Dolly
  class SimpleReplicator
    include Dolly::Replication::Database

    attr_reader :source_db, :target_db

    def initialize source_db, target_db, opts={}
      #@opts = opts #TODO add options for difference replications
      @source_db = source_db
      @target_db = target_db
    end

    def replicate!
      database.request :post, '/_replicate', {body: request_body}
    end

    private

    def request_body
      {
        source: source_db,
        target_db: target_db
      }.to_json
    end

  end
end
