module Dolly
  class ResourceNotFound < RuntimeError
    def to_s
      'The document was not found.'
    end
  end
  class ServerError < RuntimeError
    def to_s
      'There has been an error on the couchdb server. Please review your couch logs.'
    end
  end
end
