require "dolly/version"
require "dolly/document"
require "dolly/property"

module Dolly

  class Base
    include Dolly::Document
    attr_accessor :rows, :doc, :key

    def rows= col
      col.each{ |r| @doc = r['doc'] }
      _properties.each do |p|
        self.send "#{p.name}=", doc[p.name]
      end
      @rows = col
    end

    def self.property *ary
      options       = ary.pop if ary.last.kind_of? Hash
      options     ||= {}
      @properties ||= []

      @properties += ary.map do |name|
        options.merge!({name: name})
        property = Property.new(options)

        define_method(name) do
          property.value = @doc[name.to_s]
          property.value
        end

        define_method("[]") do |n|
          send n.to_sym
        end

        define_method("#{name.to_s}=") do |val|
          @doc[name.to_s] = val
        end

        property
      end
    end

    private
    def _properties
      self.class.properties
    end
  end

end
