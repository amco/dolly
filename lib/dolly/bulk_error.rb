module Dolly
  class BulkError
    attr_accessor :obj, :name, :message

    def initialize errors = {}
      self.obj = errors['obj']
      self.name = errors['error']
      self.message = errors['reason']
    end

  end
end
