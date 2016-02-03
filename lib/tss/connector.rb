# frozen_string_literal: true

require 'httparty'
require 'net/http'

module TSS
  # Utility class encapsulating synchronous communication with TSS.
  class Connector
    include HTTParty

    base_uri TSS.configuration.base_uri

    def self.auth_credentials
      @auth_credentials ||= {
        basic_auth: {
          username: TSS.configuration.secret.freeze,
          password: TSS.configuration.password.freeze
        }
      }.freeze
    end

    attr_reader :oid
    def initialize(organization_id)
      @oid = organization_id
    end

    # @param [String] - organization_id
    # @raise [RuntimeError] TSS request failed
    def organization
      path = "/v1/organizations/#{oid}"
      p path
      response = self.class.authenticated_get(path)

      handle_get_response(response, path, 'organization')
    end

    # @raise [RuntimeError] TSS request failed
    def transactions
      path = "#{base_path}/transactions"
      response = self.class.authenticated_get(path)

      handle_get_response(response, path, 'transactions')
    end

    # @raise [RuntimeError] TSS request failed
    def transaction(transaction_id)
      path = "#{base_path}/transactions/#{transaction_id}"
      response = self.class.authenticated_get(path)

      handle_get_response(response, path, 'transaction')
    end

    # @raise [RuntimeError] TSS request failed
    def add_bank_account(bank_token)
      path = "#{base_path}/bank_accounts"
      response = self.class.authenticated_post(
        path, query: { bank_token: bank_token }
      )

      handle_post_response(response, path)
    end

    private

    # Define variants of all HTTParty request methods with authentication
    # support.
    self::Request::SupportedHTTPMethods
      .map { |x| x.name.demodulize.downcase }.each do |method|
      define_singleton_method("authenticated_#{method}") do |path, options = {}|
        send(method, path, options.merge(auth_credentials))
      end
    end

    def base_path
      "/v1/#{oid}"
    end

    def handle_post_response(response, path)
      case response.code
      when 200, 201 then JSON.parse(response.body)
      else fail "RSS: 'POST #{path}' failed with status = #{response.code}."
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
