module Dolly
  class ResourceNotFound < RuntimeError
    def to_s
      'The document was not found'
    end
  end
end
