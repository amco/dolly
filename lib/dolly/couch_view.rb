module Dolly
  class CouchView
    extend Forwardable

    ACTIVITY_CHECK_DELAY = 0.5 # seconds

    def_delegators :@doc, :[], :[]=, :to_json

    attr_reader :id, :type
    # todo make this into a proper enum once we have that ported to our Property code
    attr_accessor :status

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

    def copy_id
      "#{id}_copy"
    end

    def bulk_save
      model = Document.new
      model.doc = @doc
      Document.bulk_document << model
    end

    def saving?
      status == :saving
    end

    def document_save
      # todo change to an exception?
      return if saving?

      fork do
        self.status = :saving

        create_and_index_copy
        move_copy_to_self

        self.status = :saved

        # todo change this to be a logging statement?
        puts "View #{id} was pushed and index recreated."
      end
      Process.wait
    end

    def create_and_index_copy
      create_copy
      index_copy
    end

    def create_copy
      @copy_doc = @doc.except :_id, :_rev

      @copy_doc[:_id] = copy_id
      @copy_doc[:_rev] = existing_copy['_rev'] if existing_copy

      push_document @copy_doc
    end

    def existing_copy
      d = Document.database.get copy_id
      JSON.parse d.parsed_response
    rescue ResourceNotFound
      nil
    end

    def push_document doc
      Document.database.put doc[:_id], doc.to_json
    end

    def index_copy
      trigger_copy_index
      wait_for_indexing
    end

    def trigger_copy_index
      Document.database.trigger_index( "#{copy_id}/_view/#{any_view}" )
    end

    def any_view
      views.keys.sample
    end

    def wait_for_indexing
      while true
        return if indexing_finished?
        sleep ACTIVITY_CHECK_DELAY
      end
    end

    def indexing_finished?
      running_tasks = Document.database.activity_tasks
      running_tasks.none? { |r| r["design_document"] == copy_id }
    end

    def move_copy_to_self
      # todo refesh from the DB and only push if our _rev hasn't advanced?
      push_document @doc

    ensure
      remove_document @copy_doc
    end

    def remove_document doc
      Document.database.delete "#{doc[:_id]}?rev=#{doc[:_rev]}"
    end

  end
end
