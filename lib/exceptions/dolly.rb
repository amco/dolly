module Dolly
  class ResourceNotFound < RuntimeError
    def to_s
      'The document was not found.'
    end
  end
  class ServerError < RuntimeError
    def initialize msg
      @msg = msg
    end

    def to_s
      "There has been an error on the couchdb server: #{@msg.inspect}"
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
  class InvalidProperty < RuntimeError
    def to_s
      "Trying to set an undefined property."
    end
  end
  class DocumentInvalidError < RuntimeError; end
  class MissingPropertyError < RuntimeError; end
  class MissingRequestConfigSettings < RuntimeError
    def initialize key
      @key = key
    end

    def to_s
      "Missing required #{@key} setting for Dolly::Request"
    end
  end
end
