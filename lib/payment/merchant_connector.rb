# frozen_string_literal: true

require 'httparty'
require 'net/http'
require_relative 'http_retriever'
require_relative 'response_handlers'

module ShorePayment
  # Utility class encapsulating synchronous communication with Shore's Payment
  #   Service for specific Merchant objects.
  class MerchantConnector
    include ResponsesHandlers
    attr_reader :mid

    # Create a new +ShorePayment::MerchantConnector+ instance bound to a
    #   specific +Merchant+ ID (see +#mid+).
    #
    # @param mid [String] +Merchant+ ID. UUID format.
    #
    # @return [ShorePayment::MerchantConnector]
    def initialize(mid)
      @mid = mid
    end

    # Retrieve the current +Merchant+ (see +#mid+).
    #
    # @return [Hash<String,Object>] JSON representation of the +Merchant+.
    # @raise [RuntimeError] Request failed.
    def get_merchant # rubocop:disable AccessorMethodName
      path = base_path
      response = HttpRetriever.authenticated_get(path)
      handle_response(:get, response, path, 'merchant')
    end

    # Create the current +Merchant+ (see +#mid+).
    #
    # @param meta [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Merchant+.
    # @raise [RuntimeError] Request failed.
    def create_merchant(current_user, meta = {})
      path = base_path
      query = { current_user: current_user, meta: meta }
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
    end

    # Update non-stripe attributes on the current merchant
    #
    # @param current_user [String] the currently logged in user.
    # @param attributes [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Merchant+.
    # @raise [RuntimeError] Request failed.
    def update_merchant(current_user, attributes)
      path = base_path
      query = attributes.merge(current_user: current_user)
      response = HttpRetriever.authenticated_put(path, query: query)
      handle_response(:put, response, path)
    end

    # Retreive a list of all +Charge+s for the current +Merchant+ (see
    # +#mid+).
    #
    # @return [Array<Hash>] JSON representations of all +Charge+s.
    # @raise [RuntimeError] Request failed.
    def get_charges(query)
      path = "#{base_path}/charges"
      response = HttpRetriever.authenticated_get(path, query: query)
      handle_response(:get, response, path)
    end

    # Retrieve a specific +Charge+ for the current +Merchant+ (see
    # +#mid+).
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

    # Create a +Charge+ for the current +Merchant+ (see +#mid+).
    #
    # @param meta [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Charge+.
    # @raise [RuntimeError] Request failed.
    def create_charge(current_user, params)
      path = "#{base_path}/charges"
      CreateChargeParams.verify_params(params)
      query = { current_user: current_user }.merge(params)
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
    end

    # Capture a previously uncaptured +Charge+ for the current +Merchant+ (see
    #   +#mid+).
    #
    # @param current_user [String] ID of the user
    # @param charge_id [Integer] ID of the +Charge+ object to update.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Charge+.
    # @raise [RuntimeError] Request failed.
    def capture_charge(current_user, charge_id)
      path = "#{base_path}/charges/#{charge_id}/capture"
      query = { current_user: current_user }
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
    end

    # Create a Refund for the current +Charge+ (see +#charge_id+).
    #
    # @param meta [String] charge_id
    # @param meta [String] amount_refunded_cents
    #
    # @return [String] charge_id of the refunded charge
    # @raise [RuntimeError] Request failed.
    def create_refund(current_user:, charge_id:, amount_refunded_cents:)
      query = { current_user: current_user,
                amount_refunded_cents: amount_refunded_cents
      }

      path = "#{base_path}/charges/#{charge_id}/refund"
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
    end

    # Create a new +BankAccount+ for the current +Merchant+ (see +#mid+).
    #
    # @param bank_token [String] Token generated via Stripe's API.
    #
    # @return [Hash<String,Object>] JSON representation of the +BankAccount+.
    # @raise [RuntimeError] Request failed.
    def add_bank_account(current_user, bank_token)
      path = "#{base_path}/bank_accounts"
      query = { current_user: current_user, bank_token: bank_token }
      response = HttpRetriever.authenticated_post(path, query: query)
      handle_response(:post, response, path)
    end

    # Create or edit +StripeAccount+ for the current +Merchant+ (see
    # +#mid+).
    #
    # @param legal_entity [Hash<String,Object>] Legal Entity.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Merchant+.
    # @raise [RuntimeError] Request failed.
    def add_stripe_account(current_user, stripe_payload)
      path = "#{base_path}/stripe"
      query = { current_user: current_user }.merge(stripe_payload)
      response = HttpRetriever.authenticated_put(path, query: query)
      handle_response(:put, response, path)
    end

    private

    def base_path
      "/v1/merchants/#{mid}"
    end

    # :nodoc:
    module CreateChargeParams
      REQUIRED_PARAMS = %w(credit_card_token amount_cents currency).freeze
      OPTIONAL_PARAMS = %w(customer_name customer_address customer_email
                           statement_descriptor services description
                           capture).freeze

      def self.verify_params(params)
        params.symbolize_keys!
        verify_required_params(params)
        verify_unknown_params(params)
      end

      def self.verify_required_params(params)
        REQUIRED_PARAMS.each do |required|
          raise "Parameter #{required} missing" unless params.key?(required)
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
