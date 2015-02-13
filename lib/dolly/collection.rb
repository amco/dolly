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

    def first
      to_a.first
    end

    def last
      to_a.last
    end

    def map &block
      load if empty?
      @set.collect &block
    end

    alias_method :collect, :map

    def flat_map &block
      map( &block ).flatten
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

    def rows= ary
      ary.each do |r|
        next unless r['doc']
        properties = r['doc']
        id = properties.delete '_id'
        rev = properties.delete '_rev' if properties['_rev']
        document = (docs_class || doc_class(id)).new properties
        document.doc = properties.merge({'_id' => id, '_rev' => rev})
        @set << document
      end
      @rows = ary
    end

    def load
      parsed = JSON::parse json
      self.rows = parsed['rows']
    end

    def to_json options = {}
      load if empty?
      map{|r| r.doc }.to_json(options)
    end

    private
    def docs_class
      @docs_class
    end

    def doc_class id
      # TODO: We need to improve and document the way we return
      # multiple types when querying from a class, as it might
      # be confusing. We *could* also get dolly to parse the result
      # before sending it back to the client.
      doc_class = id[/^[a-z_]+/].camelize.constantize
      docs_class == doc_class ? docs_class : doc_class
    end

    def json
      @json
    end

  end
end
