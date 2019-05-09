module Dolly
  class Collection < DelegateClass(Array)
    attr_reader :info

    def initialize(rows: [], **info)
      @info = info
      #TODO: We should raise an exception if one of the
      #      requested documents is missing
      super rows.map(&collect_docs).compact
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
      lambda do |row|
        next unless collectable_row?(row)
        klass = Object.const_get doc_type(row[:id])
        klass.from_doc(row[:doc])
      end
    end

    def doc_type(key)
      key.match(%r{^([^/]+)/})[1].split('_').collect(&:capitalize).join
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
