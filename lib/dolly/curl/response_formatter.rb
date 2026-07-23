# frozen_string_literal: true

require 'oj'
require 'dolly/framework_helper'
require 'dolly/exceptions'

module Dolly
  module Curl
    module ResponseFormatter
      include Dolly::FrameworkHelper

      private

      def response_format(res, method)
        status = res.status.to_i
        raise Dolly::ResourceNotFound if status == 404
        raise Dolly::ServerError.new(status) if (400..600).include?(status)
        return res.header_str if method == :head

        data = Oj.load(res.body_str, symbol_keys: true)
        return data unless rails?
        return data.with_indifferent_access if data.is_a?(Hash)

        data
      rescue Oj::ParseError
        res.body_str
      end
    end
  end
end
