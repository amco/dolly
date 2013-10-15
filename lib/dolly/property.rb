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
      return @default if @value.nil?
      case self_klass.try(:name)
      when nil
        @value
      when Hash.name
        @value.to_h
      when Integer.name
        @value.to_i
      when FalseClass.name
        @value =~ /true/ || @value === true
      when TrueClass.name
        @value =~ /true/ || @value === true
      else
        self_klass.new @value
      end
    end

    def boolean?
      self_klass == TrueClass || self_klass == FalseClass
    end

    private
    def self_klass
      return unless @class_name
      @class_name.is_a?(Class)? @class_name : @class_name.constantize
    end

  end
end
