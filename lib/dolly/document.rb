require "dolly/query"
require "dolly/property"
require 'dolly/timestamps'
require "dolly/mango_query"
require 'dolly/scope'

module Dolly
  class Document
    extend Dolly::Connection
    include Dolly::Query
    extend Dolly::Timestamps

    attr_accessor :rows, :doc, :key
    class_attribute :properties, :scopes
    cattr_accessor :timestamps do
      {}
    end

    def initialize options = {}
      @doc ||= {}
      options = options.with_indifferent_access
      init_properties options
    end

    def persisted?
      !doc['_rev'].blank?
    end

    def update_properties options = {}
      raise InvalidProperty unless valid_properties?(options)
      options.each do |property, value|
        send(:"#{property}=", value)
      end
    end

    def update_properties! options = {}
      update_properties(options)
      save
    end

    def reload
      self.doc = self.class.find(id).doc
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

    def save options = {}
      return false unless options[:validate] == false || valid?
      self.doc['_id'] = self.id if self.id.present?
      self.doc['_id'] = self.class.next_id if self.doc['_id'].blank?
      set_created_at if timestamps[self.class.name]
      set_updated_at if timestamps[self.class.name]
      response = database.put(id_as_resource, self.doc.to_json)
      obj = response.parsed_response
      doc['_rev'] = obj['rev'] if obj['rev']
      obj['ok']
    end

    def save!
      raise DocumentInvalidError unless valid?
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
        #TODO: Refactor properties so it is not required
        #to be a class property. But something that doesn't
        #persist all the inheretence chain
        next unless self.respond_to? :"#{p.name}="
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

    def attach_file! file_name, mime_type, body, opts={}
      attach_file file_name, mime_type, body, opts
      save
    end

    def attach_file file_name, mime_type, body, opts={}
      if opts[:inline]
        attach_inline_file file_name, mime_type, body
      else
        attach_standalone_file file_name, mime_type, body
      end
    end

    def attach_inline_file file_name, mime_type, body
      attachment_data = { file_name.to_s => { 'content_type' => mime_type,
                                              'data'         => Base64.encode64(body)} }
      doc['_attachments'] ||= {}
      doc['_attachments'].merge! attachment_data
    end

    def attach_standalone_file file_name, mime_type, body
      database.attach id_as_resource, CGI.escape(file_name), body, { 'Content-Type' => mime_type }
    end

    def self.create options = {}
      obj = new options
      obj.save
      obj
    end

    def self.property *ary
      self.properties ||= {}
      options           = ary.pop if ary.last.kind_of? Hash
      options         ||= {}

      ary.each do |name|
        self.properties[name] = Property.new options.merge(name: name)
        self.write_methods name
      end
    end

    class << self
      def scope scope_name, scope
        self.scopes ||= {}
        name = scope_name.to_sym
        self.scopes[name] = lambda { |proxy_scope| Dolly::Scope.new(proxy_scope, scope)}

        (class << self; self end).instance_eval do
          define_method name do |*args|
            self.scopes[name].call(self)
          end
        end
      end
    end

    private
    #TODO: create a PropertiesSet service object, to do all this
    def self.write_methods name
      property = properties[name]
      define_method(name) { read_property name }
      define_method("#{name}=") { |value| write_property name, value }
      define_method(:"#{name}?") { send name } if property.boolean?
      define_method("[]") {|n| send n.to_sym }
    end

    def write_property name, value
      instance_variable_set(:"@#{name}", value)
      @doc[name.to_s] = value
    end

    def read_property name
      if instance_variable_get(:"@#{name}").nil?
        write_property name, (doc[name.to_s] || self.properties[name].value)
      end
      instance_variable_get(:"@#{name}")
    end

    def _properties
      self.properties.values
    end

    def init_properties options = {}
      raise Dolly::ResourceNotFound if options['error'] == 'not_found'
      options.each do |k, v|
        next unless respond_to? :"#{k}="
        send(:"#{k}=", v)
      end
      initialize_default_properties options if self.properties.present?
      init_doc options
    end

    def initialize_default_properties options
      _properties.reject { |property| options.keys.include? property.name }.each do |property|
        property_value = property.default.clone unless Dolly::Property::CANT_CLONE.any? { |klass| property.default.is_a? klass }
        property_value ||= property.default
        self.doc[property.name] ||= property_value
      end
    end

    def init_doc options
      self.doc ||= {}
      #TODO: define what will be the preference _id or id
      normalized_id = options[:_id] || options[:id]
      self.doc['_id'] = self.class.namespace( normalized_id ) if normalized_id
    end

    def valid_properties?(options)
      options.keys.any?{ |option| properties_include?(option.to_s) }
    end

    def properties_include? property
      _properties.map(&:name).include? property
    end

    def valid?; true; end
  end
end
