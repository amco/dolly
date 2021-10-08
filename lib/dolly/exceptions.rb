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

  class InvalidMangoOperatorError < RuntimeError
    def initialize msg
      @msg = msg
    end

    def to_s
      "Invalid Mango operator: #{@msg.inspect}"
    end
  end

  class BulkError < RuntimeError
    def intialize(error:, reason:, obj:)
      @error = error
      @reason = reason
      @obj = obj
    end

    def to_s
      "#{@error} on #{@obj} because #{@reason}."
    end
  end

  class IndexNotFoundError < RuntimeError; end
  class InvalidConfigFileError < RuntimeError; end
  class InvalidProperty < RuntimeError; end
  class DocumentInvalidError < RuntimeError; end
end
