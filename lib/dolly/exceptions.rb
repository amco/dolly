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

  class InvalidConfigFileError < RuntimeError; end
  class InvalidProperty < RuntimeError; end
  class DocumentInvalidError < RuntimeError; end
end
