# frozen_string_literal: true

require 'dolly/curl/stale_connection'
require 'dolly/curl/response_formatter'
require 'dolly/curl/document_helper'
require 'dolly/curl/reader'
require 'dolly/curl/write_reconciler'
require 'dolly/curl/connection'

module Dolly
  # Namespace for Curb-based HTTP transport collaborators.
  #
  # Public CouchDB client API remains Dolly::Connection. Classes under
  # Dolly::Curl are internal transport/retry helpers.
  module Curl
  end
end
