require "dolly/request"
require "dolly/name_space"

module Dolly
  module Connection
    include Dolly::NameSpace

    def database
      @database ||= Request.new(database_name: @@database_name)
    end

    def database_name value
       @@database_name ||= value
    end

    def default_doc
      "#{design_doc}/_view/#{name_paramitized}"
    end

    def design_doc
      "_design/#{@@design_doc || DESIGN_DOC}"
    end

    def set_design_doc value
      @@design_doc = value
    end
  end
end
