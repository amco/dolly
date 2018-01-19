module Dolly
  class Property
    attr_writer :value
    attr_accessor :name
    attr_reader :class_name, :default, :subproperties

    CANT_CLONE = [NilClass, TrueClass, FalseClass, Fixnum].freeze

    def initialize opts = {}
      @class_name = opts.delete(:class_name) if opts.present?
      @name = opts.delete(:name).to_s
      @default = opts.delete(:default)
      @default = @default.clone if @default && CANT_CLONE.none? { |klass| @default.is_a? klass }
      @subproperties = {}
      warn 'There are some unprocessed options!' if opts.present?
    end

    def value
      return value_if_subproperties if subproperties.any?
      standard_value
    end

    def subproperty *ary, &block
      options = ary.pop if ary.last.kind_of? Hash
      options ||= {}

      if options[:class_name] == Hash && block_given?
        ary.each do |name|
          @subproperties[name] = SubProperty.new options.merge(name: name)
          self.subproperties[name].instance_exec self.subproperties[name], &block
        end
      else
        ary.each do |name|
          @subproperties[name] = SubProperty.new options.merge(name: name)
        end
      end
    end

    def array_value
      @value.to_a
    end

    def hash_value
      @value.to_h
    end

    def string_value
      @value.to_s
    end

    def integer_value
      @value.to_i
    end

    def float_value
      @value.to_f
    end

    def date_value
      @value.to_date
    end

    def time_value
      @value.to_time
    end

    def date_time_value
      @value.to_datetime
    end

    def true_class_value
      truthy_value?
    end

    def false_class_value
      truthy_value?
    end

    def boolean?
      self_klass == TrueClass || self_klass == FalseClass
    end

    private
    def truthy_value?
      @value =~ /true/ || @value === true
    end

    def self_klass
      return unless @class_name
      @class_name.is_a?(Class)? @class_name : @class_name.constantize
    end

    def value_if_subproperties
      @value ||= self_klass.new.tap do |v|
        subproperties.each { |name, subproperty| v[name.to_s] = subproperty.value }
      end
    end

    def standard_value
      return @default if @value.nil?
      klass_sym = :"#{self_klass.name.underscore}_#{__method__}"
      return self_klass.new @value unless self.respond_to?(klass_sym)
      self.send klass_sym
    end

  end

  class SubProperty < Property; end
end
