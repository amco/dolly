module Dolly
  class CouchView
    extend Forwardable

    def_delegators :@doc, :[], :[]=, :to_json

    attr_reader :id, :type

    def initialize id, file_type
      @id = "_design/#{id}"
      self.type = file_type
      @doc = build_view_doc
    end

    def type= value
      raise UnsupportedFileType if value.blank?
      @type = value
    end

    def set_view view_hash
      views.merge! view_hash
    end

    def save bulk = false
      bulk ? bulk_save : document_save
    end

    def to_hash
      @doc
    end

    def rev= value
      self[:_rev] = value
    end

    def views= value
      self[:views] = value
    end

    def views
      self[:views]
    end

    private

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

    def bare_json
      d = to_hash.dup
      d.delete :_rev
      d.to_json
    end

    def bulk_save
      model = Document.new
      model.doc = @doc
      Document.bulk_document << model
    end

    def document_save
      pid = fork do
        at_exit { puts "View #{id} was pushed and index recreated." }
        push_design_start
        sleep 1 while indexing_status.present?
        push_document
      end
      Process.wait
    end

    def retrieve_tmp_doc
      d = Document.database.get tmp_id
      JSON.parse d.parsed_response
    rescue ResourceNotFound
      nil
    end

    def tmp_doc
      @tmp_doc ||= retrieve_tmp_doc
    end

    def push_design_start
      clean_tmp if tmp_doc
      @tmp_doc = JSON.parse update_tmp_design
      Document.database.trigger_index( "#{tmp_id}/_view/#{query_trigger}" )
    end

    def indexing_status
      running_tasks = Document.database.activity_tasks
      running_tasks.detect{ |r| r["design_document"] == tmp_id }
    end

    def push_document id = nil
      id ||= self[:_id]
      Document.database.put id, to_json
      clean_tmp
    end

    def update_tmp_design
      Document.database.put( tmp_id, bare_json ).parsed_response
    end

    def tmp_rev
      tmp_doc["rev"] || tmp_doc["_rev"]
    end

    def clean_tmp
      Document.database.delete "#{tmp_id}?rev=#{tmp_rev}"
      @indexing_starts = nil
    end

    def query_trigger
      views.keys.first
    end

  end
end
