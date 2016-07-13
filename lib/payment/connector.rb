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

    def initialize(locale: 'en')
      @http_retriever = HttpRetriever.new(locale: locale)
    end

    # Retrieve a filtered list of +Merchant+s
    #
    # @param params - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Merchant+s.
    # @raise [RuntimeError] Request failed.
    def get_merchants(query)
      path = '/v1/merchants/'
      response = @http_retriever.authenticated_get(path, query: query)
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
      response = @http_retriever.authenticated_get(path, query: query)
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
      response = @http_retriever.authenticated_get(path)
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
      response = @http_retriever.authenticated_put(path, query: query)
      handle_response(:put, response, path)
    end

    # Retrieve a list of supported Countries
    #
    # @return [Array[String]] JSON array of Country ISO codes.
    # @raise [RuntimeError] Request failed.
    def get_countries(query = {})
      path = '/v1/countries/'
      response = @http_retriever.authenticated_get(path, query: query)
      handle_response(:get, response, path)
    end

    # Retrieve a list with types of verification data needed to keep an account
    # open for the given +Country+
    #
    # @param country_id [String] +Country+ ID. Country ISO code.
    #
    # @return [Hash<String,Object>] JSON representation of the fields.
    # @raise [RuntimeError] Request failed.
    def get_country_verification_fields(country_id)
      path = "/v1/countries/#{country_id}/verification_fields"
      response = @http_retriever.authenticated_get(path)
      handle_response(:get, response, path)
    end

    # Retrieve a list with types of supported bank account currencies for the
    # given for the given +Country+
    #
    # @param country_id [String] +Country+ ID. Country ISO code.
    #
    # @return [Hash<String,Object>] JSON representation of the currencies.
    # @raise [RuntimeError] Request failed.
    def get_country_bank_account_currencies(country_id)
      path = "/v1/countries/#{country_id}/bank_account_currencies"
      response = @http_retriever.authenticated_get(path)
      handle_response(:get, response, path)
    end
  end
end
