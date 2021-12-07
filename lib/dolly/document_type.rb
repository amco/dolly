require 'refinements/string_refinements'

module Dolly
  module DocumentType
    using StringRefinements

    def namespace_keys(keys)
      keys.map { |key| namespace_key key }
    end

    def namespace_key(key)
      return "#{key}" if "#{key}" =~ %r{^#{name_paramitized}#{type_sep}}
      "#{name_paramitized}#{type_sep}#{key}"
    end

    def base_id
      self.id.sub(%r{^#{name_paramitized}#{type_sep}}, '')
    end

    def name_paramitized
      class_name.split("::").last.underscore
    end

    def class_name
      is_a?(Class) ? name : self.class.name
    end

    def typed?
      respond_to?(:type)
    end

    def set_type
      return unless typed?
      write_attribute(:type, name_paramitized)
    end

    def type_sep
      return ':' if partitioned?
      '/'
    end

    def partitioned?
      false
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def absolute_id(id)
        id.sub(%r{^[^/]+/}, '')
      end

      def typed_model
        property :type, class_name: String
      end

      def partitioned!
        check_db_partitioned!
        define_method(:partitioned?) { true }
      end

      def check_db_partitioned!
        !!connection.get('').
          dig(:props, :partitioned) ||
          raise(Dolly::PartitionedDataBaseExpectedError)
      end
    end
  end
end
