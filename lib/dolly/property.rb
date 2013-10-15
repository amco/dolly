module Dolly
  class Property
    attr_writer :value
    attr_accessor :name

    def initialize opts = {}
      @class_name = opts.delete(:class_name) if opts.present?
      @name = opts.delete(:name).to_s
      @default = opts.delete(:default)
      warn 'There are some unprocesed options' if opts.present?
    end

    def value
      #TODO: Get rid of the case...when, for some more readable structure
      case self_klass.try(:name)
      when nil
        @value
      when Hash.name
        @value.to_h
      when Integer.name
        @value.to_i
      when FalseClass.name
        false if !@value || @value =~ /false/
      when TrueClass.name
        true if @value || @value =~ /true/
      else
        self_klass.new @value
      end || @default
    end

    private
    def self_klass
      return unless @class_name
      @class_name.is_a?(Class)? @class_name : @class_name.constantize
    end

  end
end
