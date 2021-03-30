require 'dolly/class_methods_delegation'

module Dolly
  module ViewQuery
    def raw_view(design, view_name, opts = {})
      design = "_design/#{design}/_view/#{view_name}"
      connection.view(design, opts)
    end

    def view_value(doc, view_name, opts = {})
      raw_view(doc, view_name, opts)[:rows].flat_map { |result| result[:value] }
    end

    def collection_view(design, view_name, opts = {})
      opts.delete(:include_docs)
      design = "_design/#{design}/_view/#{view_name}"
      response = connection.view(design, opts)
      Dolly::Collection.new(rows: response, options: opts)
    end
  end
end
