require "active_model/naming"

#TODO: remove this module to be part of Dolly::Document
module Dolly
  module NameSpace
    include ActiveModel::Naming

    def name_paramitized
      model_name.element
    end

    def base_id id
      id = URI.unescape id
      id.sub %r~^#{name_paramitized}/~, ''
    end

    def namespace id
      return id if id =~ %r~^#{name_paramitized}/~
      "#{name_paramitized}/#{id}"
    end
  end
end
