require "dolly/query"
require "dolly/property"
require "dolly/property_methods"
require "dolly/couch_document"

module Dolly
  class Document
    extend Dolly::Connection
    include Dolly::Query
    include Dolly::NameSpace
    include Dolly::PropertyMethods

    attr_accessor :rows, :doc, :key
    class_attribute :properties

    def initialize options = {}
      @doc ||= {}
      @property = options.with_indifferent_access
      init_properties
    end

    def id
      doc['_id'] ||= self.class.next_id
    end

    def id= base_value
      doc['_id'] = self.class.namespace(base_value)
    end

    def rev
      doc['_rev']
    end

    def rev= value
      doc['_rev'] = value
    end

    def save
      self.doc['_id'] = self.id if self.id.present?
      self.doc['_id'] = self.class.next_id if self.doc['_id'].blank?
      response = database.put(id_as_resource, self.doc.to_json)
      obj = JSON::parse response.parsed_response
      doc['_rev'] = obj['rev'] if obj['rev']
      obj['ok']
    end

    def save!
      #TODO: decide how to handle validations...
      save
    end

    def destroy soft = false
      #TODO: Add soft delete support
      q = id_as_resource + "?rev=#{rev}"
      response = database.delete(q)
      JSON::parse response.parsed_response
    end

    def rows= col
      raise Dolly::ResourceNotFound if col.empty?
      col.each{ |r| @doc = r['doc'] }
      _properties.each do |p|
        self.send "#{p.name}=", doc[p.name]
      end
      @rows = col
    end

    def from_json string
      parsed = JSON::parse( string )
      self.rows = parsed['rows']
      self
    end

    def database
      self.class.database
    end

    def id_as_resource
      CGI::escape id
    end

    def self.create options = {}
      obj = new options
      obj.save
      obj
    end

    def self.property *ary
      options           = ary.pop if ary.last.kind_of? Hash
      options         ||= {}
      self.properties ||= []

      self.properties += ary.map do |name|
        property = Property.new( options.merge(name: name) )

        define_method(name) { @property[name.to_sym] ||= property.value }
        define_method("#{name}=") { |val| property.value = @property[name.to_sym] = val }
        define_method(:"#{name}?") { send name } if property.boolean?
        property
      end
    end

    private
    def _properties
      self.properties
    end

    def init_properties
      raise Dolly::ResourceNotFound if @property['error'] == 'not_found'
      @property.each do |k, v|
        k = 'id' if k == '_id'
        next unless respond_to? :"#{k}="
        send(:"#{k}=", v)
      end
    end

  end
end
