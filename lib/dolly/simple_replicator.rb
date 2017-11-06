module Dolly
  class SimpleReplicator
    include Dolly::Replicator::Database

    attr_reader :source_db, :target_db

    def initialize source_db, target_db
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
