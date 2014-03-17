module Dolly
  class TimeOut < RuntimeError; end

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
  class InvalidConfigFileError < RuntimeError

    def initialize filename
      @filename = filename
    end

    def to_s
      "Invalid config file at #{filename}"
    end
  end
end
