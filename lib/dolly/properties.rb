module Dolly
  module Properties
    def property *opts, class_name: nil, default_value: nil
      opts.each do |opt|
        properties << opt
        send(:attr_accessor, opt)
      end
    end

    def properties
      @properties ||= Set.new
    end
  end
end
