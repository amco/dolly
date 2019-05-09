require 'dolly/document_type'
require 'dolly/class_methods_delegation'

module Dolly
  module IdentityProperties
    include DocumentType
    include ClassMethodsDelegation

    def id
      doc[:_id] ||= namespace_key(connection.uuids.last)
    end

    def id= value
      doc[:_id] = namespace_key(value)
    end

    def rev
      doc[:_rev]
    end

    def rev= value
      doc[:_rev] = value
    end

    def id_as_resource
      CGI.escape(id)
    end
  end
end
