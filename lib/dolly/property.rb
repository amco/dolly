require 'refinements/string_refinements'

module Dolly
  class Property
    attr_reader :key, :class_name, :default
    CANT_CLONE = [NilClass, TrueClass, FalseClass, Integer]

    using StringRefinements

    def initialize(key, class_name, default = nil)
      @key = key
      @default = default
      @class_name = class_name
    end

    def cast_value(value)
      return set_default if value.nil?
      return value unless class_name
      return self_klass.new(value) unless respond_to?(klass_sym)
      send(klass_sym, value)
    end

    def boolean?
      [TrueClass, FalseClass].include?(class_name)
    end

    def hash_value(value)
      value.to_h
    end

    def integer_value(value)
      value.to_i
    end

    def float_value(value)
      value.to_f
    end

    def date_value(value)
      return value.to_date if value.respond_to?(:to_date)
      Date.parse(value)
    end

    def time_value(value)
      return value.to_time if value.respond_to?(:to_time)
      DateTime.parse(value).to_time
    end

    def date_time_value(value)
      return value.to_datetime if value.respond_to?(:to_datetime)
      DateTime.parse(value)
    end

    def true_class_value(value)
      truthy_value?(value)
    end

    def false_class_value(value)
      truthy_value?(value)
    end

    private

    def truthy_value?(value)
      value =~ /true/ || value === true
    end

    def klass_sym
      :"#{self_klass.name.underscore}_value"
    end

    def self_klass
      return unless class_name
      return class_name if class_name.is_a?(Class)
      Object.const_get class_name
    end

    def set_default
      return unless default_present?
      return default unless cant_clone_default?
      default.clone
    end

    def cant_clone_default?
      CANT_CLONE.none? { |klass| default.is_a? klass }
    end

    def default_present?
      !default.nil?
    end
  end
end
