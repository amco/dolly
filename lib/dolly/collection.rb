module Dolly
  class Collection < DelegateClass(Array)
    attr_reader :info

    def initialize(rows: [], **info)
      @info = info
      super rows.map(&collect)
    end

    def first_or_all
      single? ? first : self
    end

    def single?
      size == 1
    end

    private

    def collect
      lambda do |row|
        klass = Object.const_get doc_type(row[:id])
        klass.from_doc(row[:doc])
      end
    end

    def doc_type(key)
      key.match(%r{^([^/]+)/})[1].split('_').collect(&:capitalize).join
    end
  end
end
