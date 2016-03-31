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

    # Retrieve a filtered list of +Merchant+s
    #
    # @param params - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Merchant+s.
    # @raise [RuntimeError] Request failed.
    def get_merchants(query)
      path = '/v1/merchants/'
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path)
    end

    # Retrieve a filtered list of +Disputes+
    #
    # @param query - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Disputes+.
    # @raise [RuntimeError] Request failed.
    def get_disputes(query = {})
      path = '/v1/disputes/'
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path)
    end

    # Retrieve a specific +Dispute+
    #
    # @param dispute_id [String] +Dispute+ ID. UUID format.
    #
    # @return [Hash<String,Object>] JSON representation of the +Dispute+.
    # @raise [RuntimeError] Request failed.
    def get_dispute(dispute_id)
      path = "/v1/disputes/#{dispute_id}"
      response = HttpRetriever.authenticated_get(path)
      handle_response(:get, response, path, 'dispute')
    end

    # Update +Dispute+ (i.e. add new evidence).
    #
    # @param dispute_id [String] +Dispute+ ID.
    # @param evidence [Hash<String,Object>] Dispute evidence.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Dispute+.
    # @raise [RuntimeError] Request failed.
    def update_dispute(current_user, dispute_id, payload = {})
      path = "/v1/disputes/#{dispute_id}"
      query = { current_user: current_user }.merge(payload)
      response = HttpRetriever.authenticated_put(path, query: query)
      handle_response(:put, response, path)
    end
  end
end
