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
  class BadQueryArguement < RuntimeError
    def initialize operator, expected_type
      @operator, @expected_type = operator, expected_type
    end

    def to_s
      "The operator #{@operator} only accepts a(n) #{@expected_type}"
    end
  end
  class UnrecognizedOperator < RuntimeError
    def initialize operator
      @operator = operator
    end

    def to_s
      "The operator #{@operator} is unrecognized"
    end
  end
end
