module Dolly
  class Collection < DelegateClass(Set)
    attr_accessor :rows, :collection
    attr_writer :json, :docs_class

    def initialize collection, docs_class
      @docs_class = docs_class
      @collection = collection
      initial = []
      super(initial)
      load
    end

    def last
      to_a.last
    end

    def update_properties! properties ={}
      properties.each do |key, value|
        each do |doc|
          raise Dolly::MissingPropertyError unless doc.respond_to? key.to_sym
          doc.send(:"#{key}=", value)
        end
      end

      BulkDocument.new(Dolly::Document.database, to_a).save
      self
    end

    def each &block
      load if empty?
      super &block
      #TODO: returning nil to avoid extra time serializing set.
      nil
    end

    def rows= ary
      ary.each do |r|
        next unless r['doc']
        properties = r['doc']
        id = properties.delete '_id'
        rev = properties.delete '_rev' if properties['_rev']
        document = (docs_class || doc_class(id)).new properties
        document.doc = properties.merge({'_id' => id, '_rev' => rev})
        self << document
      end
    end

    def load
      self.rows = collection['rows']
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
      @json ||= @collection.to_json
    end

  end
end
