require "dolly/request"
require "dolly/name_space"
require "dolly/db_config"

module Dolly
  module Connection
    include Dolly::NameSpace
    include Dolly::DbConfig

    @@design_doc = nil

    def database
      @database ||= Request.new(env)
    end

    def database_name value
      @@database_name ||= value
    end

    def default_doc
      "#{design_doc}/_view/find"
    end

    def design_doc
      "_design/#{env["design"]}"
    end

  end
end
