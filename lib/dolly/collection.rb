module Dolly
  class Collection < DelegateClass(Set)
    attr_accessor :rows
    attr_writer :json, :docs_class

    def initialize str, docs_class
      @docs_class = docs_class
      @json = str
      initial = []
      super(initial)
      load
    end

    def last
      to_a.last
    end

    def update_properties! properties ={}
      properties.each do |key, value|

        regex = %r{
          \"#{key}\":  # find key definition in json string
          (            # start value group
            \"[^\"]*\" # find anything (even empty) between \" and \"
            |          # logical OR
            null       #literal null value
          )            # end value group
        }x

        raise Dolly::MissingPropertyError unless json.match regex
        json.gsub! regex, "\"#{key}\":\"#{value}\""
      end

      BulkDocument.new(Dolly::Document.database, to_a).save
      clear
      load
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

    def doc_rows= ary
      ary.each do |doc|
        id = doc.delete '_id'
        rev = doc.delete '_rev' if doc['_rev']
        document = (docs_class || doc_class(id)).new doc
        document.doc = doc.merge({'_id' => id, '_rev' => rev})
        self << document
      end
    end

    def load
      parsed = JSON::parse json
      self.rows = parsed['rows'] if parsed['rows']
      self.doc_rows = parsed['docs'] if parsed['docs']
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
