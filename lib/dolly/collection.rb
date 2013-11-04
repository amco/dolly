require 'dolly/representations/collection_representation'

module Dolly
  class Collection
    extend Forwardable
    attr_accessor :rows
    attr_writer :json, :docs_class

    def_delegators :@set, :clear, :empty?, :length, :+, :-

    def initialize str, docs_class
      @set = Set.new
      @docs_class = docs_class
      @json = str
    end

    def map &block
      load if empty?
      @set.collect &block
    end

    def each &block
      load if empty?
      @set.each &block
      #TODO: returning nil to avoid extra time serializing set.
      nil
    end

    def to_a
      load if empty?
      @set.to_a
    end

    def count
      load if empty?
      length
    end

    def load
      @set = self.extend(representation).from_json(json).rows
    end

    def to_json options = {}
      load if empty?
      map{|r| r.doc }.to_json(options)
    end

    private
    def representation
      Representations::CollectionRepresentation.config(docs_class)
    end

    def docs_class
      @docs_class
    end

    def json
      @json
    end

  end
end
