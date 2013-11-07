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
  class MissingDesignError < RuntimeError
    def to_s
      'Design document is missing. Add it into couchdb.yml as design:name.'
    end
  end
end
