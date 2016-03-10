# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'
require_relative 'response_handlers'

module ShorePayment
  # Utility class encapsulating synchronous communication with Shore's Payment
  #   Service.
  class Connector
    include ResponsesHandlers

    # Retrieve a filtered list of +Organizations+
    #
    # @param params - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Organizations+.
    # @raise [RuntimeError] Request failed.
    def get_organizations(query)
      path = '/v1/organizations/'
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path, 'organizations')
    end

    # Retrieve a filtered list of +Disputes+
    #
    # @param query - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Disputes+.
    # @raise [RuntimeError] Request failed.
    def get_disputes(query)
      path = '/v1/disputes/'
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path, 'disputes')
    end
  end
end
