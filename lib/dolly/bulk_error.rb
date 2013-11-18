module Dolly
  class BulkError
    attr_accessor :obj, :name, :message

    def initialize options = {}
      self.obj = options['obj']
      self.name = options['error']
      self.message = options['reason']
    end

    def to_s
      message
    end

  end
end
