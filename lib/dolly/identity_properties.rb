module Dolly
  module IdentityProperties
    def id
      doc[:_id] ||= self.class.namespace_key(self.class.connection.uuids.last)
    end

    def id= value
      doc[:_id] = self.class.namespace_key(value)
    end

    def rev
      doc[:_rev]
    end

    def rev= value
      doc[:_rev] = value
    end

    def id_as_resource
      CGI.escape id
    end
  end
end
