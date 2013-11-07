module Dolly
  module NameSpace
    def name_paramitized
      model_name.param_key
    end

    def base_id id
      return id unless id =~ /^#{name_paramitized}/
      base = id.split('/')
      base.shift
      base.join('/')
    end

    def namespace id
      return id if id =~ /^#{name_paramitized}/
      "#{name_paramitized}/#{id}"
    end
  end
end
