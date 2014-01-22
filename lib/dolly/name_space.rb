require "active_model/naming"

module Dolly
  module NameSpace
    include ActiveModel::Naming

    def name_paramitized
      model_name.element
    end

    def base_id id
      id = URI.unescape id
      return id unless id =~ /^#{name_paramitized}\//
      id.match("[^/]+[/](.+)")[1]
    end

    def namespace id
      return id if id =~ /^#{name_paramitized}/
      "#{name_paramitized}/#{id}"
    end
  end
end
