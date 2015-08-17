module Dolly
  class MissingDesignError < RuntimeError
    'Design document is missing. Add it into couchdb.yml as design:name.'
  end
  class InvalidConfigFileError < RuntimeError
    def initialize filename
      @filename = filename
    end

    def to_s
      "Invalid config file at #{@filename}"
    end
  end
  class InvalidProperty < RuntimeError
    def to_s
    "Trying to set an undefined property."
    end
  end
  class BadRequest400 < RuntimeError
    def to_s
    "Bad request structure. The error can indicate an error with the request URL, path or headers. Differences in the supplied MD5 hash and contentalso trigger this error, as this may indicate message corruption."
    end
  end
  class Unauthorized401 < RuntimeError
    def to_s
    "The item requested was not available using the supplied authorization, or authorization was not supplied."
    end
  end
  class Forbidden403 < RuntimeError
    def to_s
    "The requested item or operation is forbidden."
    end
  end
  class NotFound404 < RuntimeError
    def initialize response
      @response = response
    end

    def to_s
    "The requested content could not be found: #{@response.inspect}"
    end
  end
  class ResourceNotAllowed405 < RuntimeError
    def to_s
    "A request was made using an invalid HTTP request type for the URL requested.Errors of this type can also be triggered by invalid URL strings."
    end
  end
  class Unacceptable406 < RuntimeError
    def to_s
    "The requested content type is not supported by the server"
    end
  end
  class Conflict409 < RuntimeError
    def to_s
    "Request resulted in an update conflict."
    end
  end
  class PreconditionFailed412 < RuntimeError
    def to_s
    "The request headers from the client and the capabilities of the server do not match."
    end
  end
  class BadContentType415 < RuntimeError
    def to_s
    "The content types supported, and the content type of the information being requested orsubmitted indicate that the content type is not supported."
    end
  end
  class RequestedRangeNotSatisfied416 < RuntimeError
    def to_s
    "The range specified in the request header cannot be satisfied by the server."
    end
  end
  class ExpectationFailed < RuntimeError
    def to_s
    "When sending documents in bulk, the bulk load operation failed."
    end
  end
  class InternalServerError500 < RuntimeError
    def to_s
      "The request was invalid, either because the supplied JSON was invalid, or invalid information was supplied as part of the request."
    end
  end
end
