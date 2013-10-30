module Dolly
  module NameSpace
    def name_paramitized
      model_name.param_key
    end

    def namespace id
      return id if id =~ /^#{name_paramitized}/
      "#{name_paramitized}/#{id}"
    end
  end
end
