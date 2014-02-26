require "dolly/query"
require "dolly/property"

module Dolly
  class Document
    extend Dolly::Connection
    include Dolly::Query
    include Dolly::NameSpace

    attr_accessor :rows, :doc, :key
    class_attribute :properties

    def initialize options = {}
      options = options.with_indifferent_access
      init_properties options
    end

    def id
      doc['_id'] ||= self.class.next_id
    end

    def id= base_value
      doc ||= {}
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

      default_value = options[:default]

      self.properties += ary.map do |name|
        options.merge!({name: name})
        property = Property.new(options)

        define_method(name) do
          key = name.to_s
          property.value = @doc.has_key?(key) ? @doc[key] : default_value
          property.value
        end

        define_method("#{name}=") do |val|
          @doc ||={}
          @doc[name.to_s] = val
        end

        define_method(:"#{name}?") { send name } if property.boolean?
        define_method("[]") {|n| send n.to_sym}

        property
      end
    end

    private
    def _properties
      self.properties
    end

    def init_properties options = {}
      raise Dolly::ResourceNotFound if options['error'] == 'not_found'
      #TODO: right now not listed properties will be ignored
      options.each do |k, v|
        next unless respond_to? :"#{k}="
        send(:"#{k}=", v)
      end
      init_doc options
    end

    def init_doc options
      self.doc ||= {}
      #TODO: define what will be the preference _id or id
      normalized_id = options[:_id] || options[:id]
      self.doc['_id'] = self.class.namespace( normalized_id ) if normalized_id
    end

  end
end
