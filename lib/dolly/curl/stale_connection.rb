# frozen_string_literal: true

require 'curb'

module Dolly
  module Curl
    module StaleConnection
      ERRORS = [
        ::Curl::Err::GotNothingError,
        ::Curl::Err::RecvError,
        ::Curl::Err::SendError,
        ::Curl::Err::PartialFileError
      ].freeze
    end
  end
end
