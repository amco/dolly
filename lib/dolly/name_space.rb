require "active_model/naming"

#TODO: remove this module to be part of Dolly::Document
module Dolly
  module NameSpace

    def name_paramitized
      underscore name.split("::").last
    end

    def base_id id
      id = URI.unescape id
      id.sub %r~^#{name_paramitized}/~, ''
    end

    def namespace id
      return id if id =~ %r~^#{name_paramitized}/~
      "#{name_paramitized}/#{id}"
    end

    #FROM ActiveModel::Name
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

  end
end
