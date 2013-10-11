require "dolly/version"
require "dolly/document"

module Dolly

  class Base
    include Dolly::Document
    attr_accessor :rows, :doc, :key

    def rows= col
      col.each{ |r| @doc = r['doc'] }
      _properties.each do |p|
        self.send "#{p}=", doc[p.to_s]
      end
      @rows = col
    end

    def self.property *ary
      #TODO: add options for representable.
      @properties ||= []
      @properties += ary

      ary.each do |name|
        define_method(name) { @doc[name.to_s] }
        define_method("#{name.to_s}=") {|val| @doc[name.to_s] = val}
      end
    end

    private
    def _properties
      self.class.properties
    end
  end

end
