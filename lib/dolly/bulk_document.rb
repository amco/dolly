module Dolly
  class BulkDocument
    extend Forwardable

    DOC_NAME = '_bulk_docs'

    attr_reader :payload, :connection
    attr_accessor :errors, :response

    def_delegators :docs, :[], :<<

    def initialize(connection, ary = [])
      @connection = connection
      @payload = Hash.new
      payload[:docs] = ary
    end

    def docs
      payload[:docs]
    end

    def save
      return if docs.empty?
      self.response = connection.post(DOC_NAME, docs_payload)
      build_errors
      update_revs
    end

    def delete
      return if docs.empty?
      connection.post DOC_NAME, json_payload(_deleted: true)
    end

    def clear
      self.payload[:docs] = []
      self.response = []
      self.errors = []
    end

    def with_errors?
      response_errors.present?
    end

    private

    def update_revs
      response.each do |doc|
        next if doc[:error]
        item = payload[:docs].detect { |d| d.id == doc[:id] }

        if item.nil?
          errors << response_error(item)
          next
        end

        item.rev = doc[:rev]
        payload[:docs].delete(item)
      end

      clean_response
    end

    def clean_response
      response.delete_if { |d| !d[:error] }
    end

    def build_errors
      self.errors = response_errors.map do |err|
        obj = payload[:docs].detect { |d| d.id == err[:id]} if err[:id]
        BulkError.new err.merge!(obj: obj)
      end
    end

    def docs_payload opts = {}
      { docs: docs.map {|d| d.to_h.merge(opts) } }
    end

    def response_errors
      self.response.select{ |d| d[:error] }
    end

    def response_error(item)
      BulkError.new(error: 'Document saved but not local rev updated.', reason: "Document with id #{doc['id']} on bulk doc was not found in payload.", obj: nil)
    end
  end
end
