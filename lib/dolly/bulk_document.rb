require 'dolly/bulk_error'

module Dolly
  class BulkDocument
    include Enumerable
    extend Forwardable

    DOC_NAME  = "_bulk_docs".freeze

    attr_reader :payload, :database
    attr_accessor :errors, :response

    def_delegators :docs, :[], :<<

    def initialize database, ary = []
      @database = database
      @payload = Hash.new
      self.payload[:docs] = ary
    end

    def docs
      self.payload[:docs]
    end

    def save
      return if docs.empty?
      self.response = self.database.post(DOC_NAME, json_payload)
      build_errors
      update_revs
    end

    def delete
      return if docs.empty?
      database.post DOC_NAME, json_payload("_deleted" => true)
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
      self.response.each do |doc|
        next if doc['error']
        item = self.payload[:docs].detect{|d| d.id == doc['id']}
        if item.nil?
          self.errors << BulkError.new({"error" => "Document saved but not local rev updated.", "reason" => "Document with id #{doc['id']} on bulk doc was not found in payload.", "obj" => nil})
          next
        end
        item.doc['_rev'] = doc['rev']
        self.payload[:docs].delete item
      end
      clean_response
    end

    def clean_response
      self.response.delete_if {|doc| !doc['error'] }
    end

    def build_errors
      self.errors = response_errors.map do |err|
        obj = self.payload[:docs].detect{|d| d.id == err['id']} if err['id']
        BulkError.new err.merge!("obj" => obj)
      end
    end

    def bare_docs
      self.payload[:docs].map(&:doc)
    end

    def json_payload opts = {}
      {docs: bare_docs.map{|d| d.merge(opts)} }.to_json
    end

    def response_errors
      self.response.select{|d| d['error']}
    end
  end
end
