# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'

module TSS
  # Utility class encapsulating synchronous communication with TSS.
  class Connector
    attr_reader :oid

    # Create a new +Connector+ instance bound to a specific +Organization+ ID
    # (see +#oid+).
    #
    # @param oid [String] +Organization+ ID. UUID format.
    #
    # @return [Connector]
    def initialize(oid)
      @oid = oid
    end

    # Retrieve a filtered list of +Organizations+
    #
    # @param params - filter and cursor (limit, start) parameters
    #
    # @return [Array[Hash<String,Object>]] JSON array of +Organizations+.
    # @raise [RuntimeError] Request failed.
    def get_organizations(**params)
      path = '/v1/organizations/'
      response = HttpRetriever.authenticated_get(path, params)
      handle_get_response(response, path, 'organizations')
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

    def handle_post_response(response, path)
      case response.code
      when 200, 201 then JSON.parse(response.body)
      else fail "TSS: 'POST #{path}' failed with status = #{response.code}."
      end
    end

    def handle_get_response(response, path, root_name)
      case response.code
      when 200 then JSON.parse(response.body)[root_name]
      when 404 then nil
      else fail "TSS: 'GET #{path}' failed with status = #{response.code}."
      end
    end
  end
end
