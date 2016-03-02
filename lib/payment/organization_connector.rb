# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'
require_relative 'response_handlers'
require_relative 'stripe'

module ShorePayment
  # Utility class encapsulating synchronous communication with Shore's Payment
  #   Service for specific Organization objects.
  class OrganizationConnector
    include ResponsesHandlers
    attr_reader :oid

    # Create a new +ShorePayment::OrganizationConnector+ instance bound to a
    #   specific +Organization+ ID (see +#oid+).
    #
    # @param oid [String] +Organization+ ID. UUID format.
    #
    # @return [ShorePayment::OrganizationConnector]
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
      handle_response(:get, response, path, 'organization')
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
      handle_response(:post, response, path)
    end

    # Retreive a list of all +Charge+s for the current +Organization+ (see
    # +#oid+).
    #
    # @return [Array<Hash>] JSON representations of all +Charge+s.
    # @raise [RuntimeError] Request failed.
    def get_charges(query)
      path = "#{base_path}/charges"
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path, 'charges')
    end

    # Retrieve a specific +Charge+ for the current +Organization+ (see
    # +#oid+).
    #
    # @param charge_id [String] +Charge+ ID. UUID format.
    #
    # @return [Hash<String,Object>] JSON representation of the +Charge+.
    # @raise [RuntimeError] Request failed.
    def get_charge(charge_id)
      path = "#{base_path}/charges/#{charge_id}"
      response = HttpRetriever.authenticated_get(path)
      handle_response(:get, response, path, 'charge')
    end

    # Create a +Charge+ for the current +Organization+ (see +#oid+).
    #
    # @param meta [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Charge+.
    # @raise [RuntimeError] Request failed.
    def create_charge(params)
      path = "#{base_path}/charges"
      CreateChargeParams.verify_params(params)
      response = HttpRetriever.authenticated_post(path, query: params)
      handle_response(:post, response, path)
    end

    # Create a Refund for the current +Charge+ (see +#charge_id+).
    #
    # @param meta [String] charge_id
    # @param meta [String] amount_refunded_cents
    #
    # @return [String] charge_id of the refunded charge
    # @raise [RuntimeError] Request failed.
    def create_refund(charge_id:, amount_refunded_cents:)
      query = { charge_id: charge_id,
                amount_refunded_cents: amount_refunded_cents
      }

      path = "#{base_path}/charges/#{charge_id}/refund"
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
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
      handle_response(:post, response, path)
    end

    # Create or edit +StripeAccount+ for the current +Organization+ (see
    # +#oid+).
    #
    # @param legal_entity [Hash<String,Object>] Legal Entity.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Organization+.
    # @raise [RuntimeError] Request failed.
    def add_stripe_account(stripe_payload)
      path = "#{base_path}/stripe"
      response = HttpRetriever.authenticated_put(path, query: stripe_payload)
      handle_response(:put, response, path)
    end

    private

    def base_path
      "/v1/organizations/#{oid}"
    end

    # :nodoc:
    module CreateChargeParams
      REQUIRED_PARAMS = [:credit_card_token, :amount_cents, :currency].freeze
      OPTIONAL_PARAMS = [:customer_name, :customer_address, :customer_email,
                         :services, :description].freeze

      def self.verify_params(params)
        verify_required_params(params)
        verify_unknown_params(params)
      end

      def self.verify_required_params(params)
        REQUIRED_PARAMS.each do |required|
          raise 'Parameter #{required} missing' unless params.key?(required)
        end
      end

      def self.verify_unknown_params(params)
        all_params = Set.new(REQUIRED_PARAMS + OPTIONAL_PARAMS)
        params.each_key do |p|
          raise "Unknown parameter #{p} passed in" unless all_params.member?(p)
        end
      end
    end
  end
end
