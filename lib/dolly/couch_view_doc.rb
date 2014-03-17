module Dolly
  class CouchViewDoc
    extend Forwardable

    DEFAULT_TIMEOUT = 10

    def_delegators :@doc, :[], :[]=, :to_json

    attr_reader :id, :type, :timeout

    def initialize id, type
      @id = "_design/#{id}"
      @type = type
      @doc = build_view_doc
    end

    def timeout
      @timeout ||= DEFAULT_TIMEOUT
    end

    def timeout= time
      @timeout = time
    end

    def save bulk = false
      bulk ? bulk_save : document_save
    end

    def rev= value
      self[:_rev] = value
    end

    def views= value
      self[:views] = value
    end

    def build_view_doc
      {
        _id: id,
        language: type,
        views: {}
      }
    end

    def tmp_id
      "#{id}_tmp"
    end

    def to_hash
      @doc
    end

    def bare_json
      d = to_hash.dup
      d.delete :_rev
      d.to_json
    end

    def bulk_save
      model = Dolly::Document.new
      model.doc = @doc
      Dolly::Document.bulk_document << model
    end

    def document_save
      push_design_start unless @indexing_starts
      return push_document unless indexing_status.present?
      raise DollyError::TimeOut if timed_out
      document_save
    end

    def retrieve_tmp_doc
      d = Dolly::Document.database.get tmp_id
      JSON.parse d.parsed_response
    rescue
      nil
    end

    def tmp_doc
      @tmp_doc ||= retrieve_tmp_doc
    end

    def push_design_start
      clean_tmp if tmp_doc
      @tmp_doc = JSON.parse push_tmp_doc
      Dolly::Document.database.trigger_index( tmp_id )
      @indexing_starts ||= Time.now()
    end

    def indexing_status
      running_tasks = Dolly::Document.database.activity_tasks
      running_tasks.detect{ |r| r["design_document"] == new_id }
    end

    def push_document id = nil
      id ||= self[:_id]
      Dolly::Document.database.put id, to_json
      clean_tmp
    end

    def push_tmp_doc
      Dolly::Document.database.put( tmp_id, bare_json ).parsed_response
    end

    def tmp_rev
      tmp_doc["rev"] || tmp_doc["_rev"]
    end

    def clean_tmp
      Dolly::Document.database.delete "#{tmp_id}?rev=#{tmp_rev}"
      @indexing_starts = nil
    end

    def timed_out
      @indexing_starts.seconds.to_i == timeout
    end

  end
end
