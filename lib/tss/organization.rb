# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'
require_relative 'response_handlers'

module TSS
  # Utility class encapsulating synchronous communication with TSS
  # for organization objects.
  class Organization
    include ResponsesHandlers
    attr_reader :oid

    # Create a new +TSS::Organization+ instance bound to a specific
    # +Organization+ ID
    # (see +#oid+).
    #
    # @param oid [String] +Organization+ ID. UUID format.
    #
    # @return [TSS::Organization]
    def initialize(oid)
      @oid = oid
    end

    # Retrieve the current +Organization+ (see +#oid+).
    #
    # @return [Hash<String,Object>] JSON representation of the +Organization+.
    # @raise [RuntimeError] Request failed.
    def get_organization # rubocop:disable AccessorMethodName
      path = base_path
      response = HttpRetriever.authenticated_get(path)
      handle_get_response(response, path, 'organization')
    end

    # Create the current +Organization+ (see +#oid+).
    #
    # @param meta [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Organization+.
    # @raise [RuntimeError] Request failed.
    def create_organization(meta = {})
      path = base_path
      query = { meta: meta }
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_post_response(response, path)
    end

    # Retreive a list of all +Transaction+s for the current +Organization+ (see
    # +#oid+).
    #
    # @return [Array<Hash>] JSON representations of all +Transaction+s.
    # @raise [RuntimeError] Request failed.
    def get_transactions # rubocop:disable AccessorMethodName
      path = "#{base_path}/transactions"
      response = HttpRetriever.authenticated_get(path)
      handle_get_response(response, path, 'transactions')
    end

    # Retrieve a specific +Transaction+ for the current +Organization+ (see
    # +#oid+).
    #
    # @param transaction_id [String] +Transaction+ ID. UUID format.
    #
    # @return [Hash<String,Object>] JSON representation of the +Transaction+.
    # @raise [RuntimeError] Request failed.
    def get_transaction(transaction_id)
      path = "#{base_path}/transactions/#{transaction_id}"
      response = HttpRetriever.authenticated_get(path)
      handle_get_response(response, path, 'transaction')
    end

    # Create a new +BankAccount+ for the current +Organization+ (see +#oid+).
    #
    # @param bank_token [String] Token generated via Stripe's API.
    #
    # @return [Hash<String,Object>] JSON representation of the +BankAccount+.
    # @raise [RuntimeError] Request failed.
    def add_bank_account(bank_token)
      path = "#{base_path}/bank_accounts"
      query = { bank_token: bank_token }
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_post_response(response, path)
    end

    private

    def base_path
      "/v1/organizations/#{oid}"
    end
  end
end
