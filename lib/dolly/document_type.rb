require 'refinements/string_refinements'

module Dolly
  module DocumentType
    using StringRefinements

    def namespace_keys(keys)
      keys.map { |key| namespace_key key }
    end

    def namespace_key(key)
      return key if key =~ %r{^#{name_paramitized}/}
      "#{name_paramitized}/#{key}"
    end

    def base_id(id)
      id.sub(%r{^#{name_paramitized}/}, '')
    end

    def name_paramitized
      class_name.split("::").last.underscore
    end

    def class_name
      is_a?(Class) ? name : self.class.name
    end
  end
end
