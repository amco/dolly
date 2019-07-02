require 'dolly/class_methods_delegation'

module Dolly
  module ViewQuery
    def raw_view(doc, view_name, opts = {})
      design = "_design/#{doc}/_view/#{view_name}"
      connection.view(design, opts)
    end

    def view_value(doc, view_name, opts = {})
      raw_view(doc, view_name, opts)[:rows].flat_map { |result| result[:value] }
    end
  end
end
