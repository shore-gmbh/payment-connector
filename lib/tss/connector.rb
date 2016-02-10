# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'

module TSS
  # Utility class encapsulating synchronous communication with TSS.
  class Connector
    attr_reader :oid

    # @param [String] - organization_id
    def initialize(organization_id)
      @oid = organization_id
    end

    # @raise [RuntimeError] TSS request failed
    def get_organization # rubocop:disable AccessorMethodName
      path = "/v1/organizations/#{oid}"
      response = HttpRetriever.authenticated_get(path)

      handle_get_response(response, path, 'organization')
    end

    # @param organization_id [String] UUID format.
    # @param meta [Hash<String,Object>] JSON serializable dictionary.
    # @raise [RuntimeError] TSS request failed
    def create_organization(organization_id, meta = {})
      path = "/v1/organizations/#{organization_id}"
      response = HttpRetriever.authenticated_post(path, query: { meta: meta })

      handle_post_response(response, path)
    end

    # @raise [RuntimeError] TSS request failed
    def get_transactions # rubocop:disable AccessorMethodName
      path = "#{base_path}/transactions"
      response = HttpRetriever.authenticated_get(path)

      handle_get_response(response, path, 'transactions')
    end

    # @param [String] - transaction_id
    # @raise [RuntimeError] TSS request failed
    def get_transaction(transaction_id)
      path = "#{base_path}/transactions/#{transaction_id}"
      response = HttpRetriever.authenticated_get(path)

      handle_get_response(response, path, 'transaction')
    end

    # @param [String] - bank_token
    # @raise [RuntimeError] TSS request failed
    def add_bank_account(bank_token)
      path = "#{base_path}/bank_accounts"
      response = HttpRetriever.authenticated_post(
        path, query: { bank_token: bank_token }
      )

      handle_post_response(response, path)
    end

    private

    def base_path
      "/v1/#{oid}"
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
