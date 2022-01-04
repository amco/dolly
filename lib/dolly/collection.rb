require 'delegate'

module Dolly
  class Collection < SimpleDelegator
    attr_reader :options

    def initialize(rows: [], options: {})
      @options = options
      #TODO: We should raise an exception if one of the
      #      requested documents is missing
      super rows[:rows].map(&collect_docs).compact
    end

    def first_or_all(forced_first = false)
      return self if forced_first
      single? ? first : self
    end

    def single?
      size <= 1
    end

    private

    def collect_docs
      proc do |row|
        next unless collectable_row?(row)
        klass = Object.const_get(doc_model(row))
        klass.from_doc(row[:doc])
      end
    end

    def doc_model(doc)
      options[:doc_type] || constantize_key(doc[:doc_type]) || constantize_key(doc_type_for(doc[:id]))
    end

    def doc_type_for(key)
      return false if key.nil?
      key.match(%r{^([^/]+)/})[1]
    end

    def constantize_key(key)
      return false if key.nil?
      key.split('_').collect(&:capitalize).join
    end

    def collectable_row?(row)
      !deleted_doc?(row) && row[:error].nil?
    end

    def deleted_doc?(row)
      value = row&.fetch(:value, {})
      return false unless value.is_a? Hash
      value.fetch(:deleted, false)
    end
  end
end
