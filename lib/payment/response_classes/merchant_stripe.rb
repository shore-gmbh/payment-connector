module ShorePayment
  # Conversion between day of birth's Hash and Date representation
  module DobConvertible
    def dob_date
      return unless @dob && dob_present?
      Date.new(@dob.year.to_i, @dob.month.to_i, @dob.day.to_i)
    end

    def dob_date=(new_date)
      date = new_date.to_date
      @dob = DateOfBirth.new(
        year: date.year,
        month: date.month,
        day: date.day
      ) if date
    rescue
      nil
    end

    private

    def dob_present?
      @dob.year.present? && @dob.month.present? && @dob.day.present?
    end
  end

  # Representation of a {DOB} object in the Merchant response
  class DateOfBirth < StripeHash
    attr_accessor :day, :month, :year
  end

  # Representation of an {Address} object in the Merchant response
  class Address < StripeHash
    attr_accessor :city, :country, :line1, :line2, :postal_code, :state
  end

  # Representation of a {CustomerAddress} object in the Charge response
  class CustomerAddress < StripeHash
    attr_accessor :city, :street, :zip
  end

  # Representation of a {Service} object in the Charge response
  class Service < StripeHash
    attr_accessor :service_name, :service_price_cents
  end

  # Representation of an {AdditionalOwner} object in the Merchant response
  class AdditionalOwner < StripeHash
    include DobConvertible

    attr_accessor :address, :first_name, :last_name, :dob, :verification

    def address=(attrs)
      @address = Address.new(attrs)
    end

    def dob=(attrs)
      @dob = DateOfBirth.new(attrs)
    end

    def verification=(attrs)
      @verification = Verification.new(attrs)
    end
  end

  # Representation of a {LegalEntity} object in the Merchant response
  class LegalEntity < StripeHash
    include DobConvertible

    attr_accessor :additional_owners, :address, :business_name,
                  :business_tax_id, :business_tax_id_provided, :dob,
                  :first_name, :last_name, :type, :verification,
                  :personal_id_number, :personal_id_number_provided,
                  :ssn_last_4, :ssn_last_4_provided

    def update_attributes(attrs = {})
      super
      # We have to set additional owners to an empty string to delete
      #   previously added additional owners.
      @additional_owners = '' if @type == 'individual' || number_of_owners == 1
    end

    def address=(attrs)
      @address = Address.new(attrs)
    end

    def additional_owners=(attrs)
      # We always build a new array of additional owners, because there is no
      #   such thing as editing a single additional owner.
      # Setting additional_owners to an empty string means that stripe API
      #   should delete all previously added additional owners
      @additional_owners = if !attrs.present?
                             attrs
                           else
                             attrs = attrs.values if attrs.respond_to?(:values)
                             attrs.map { |a| AdditionalOwner.new(a) }
                           end
    end

    def dob=(attrs)
      @dob = DateOfBirth.new(attrs)
    end

    def verification=(attrs)
      @verification = Verification.new(attrs)
    end

    # All stripe account have at least one owner, and accounts with company
    #   type could have 0..3 additional owners
    def number_of_owners
      (additional_owners || []).length + 1
    end

    def as_hash(with_nil = false)
      r = JSON.parse(to_json)
      deep_reject_nil!(r) unless with_nil
      r
    end

    private

    def deep_reject_nil!(h)
      h.each_key do |k|
        deep_reject_nil!(h[k]) if h[k].is_a?(Hash)
        next unless h[k].is_a?(Array)
        h[k].each do |a|
          deep_reject_nil!(a)
        end
      end
      h.reject! { |_k, v| v.nil? || v == {} }
    end
  end

  # Representation of an {ActiveBankAccount} object in the Merchant response
  class ActiveBankAccount < StripeHash
    attr_accessor :bank_name, :currency, :created_at, :last4, :name, :status

    def date_created
      created_at.try { |d| Date.parse(d) }
    end
  end

  # Representation of a {Stripe} object in the Merchant response
  class MerchantStripe < StripeHash
    attr_accessor :account_id, :active_bank_accounts, :charges_count,
                  :last_charge_created_at, :legal_entity, :meta,
                  :publishable_key, :verification_disabled_reason,
                  :verification_due_by, :verification_fields_needed,
                  :transfers_enabled, :charges_enabled, :country

    def initialize(attrs = nil)
      # Empty stripe object with all the necessery empty nodes
      attrs ||= {
        legal_entity: {
          additional_owners: {},
          address: {},
          verification: {}
        },
        active_bank_accounts: {}
      }
      super
    end

    def legal_entity=(attrs)
      @legal_entity = LegalEntity.new(attrs)
    end

    def active_bank_accounts=(attrs)
      @active_bank_accounts = []

      @active_bank_accounts = attrs.map do |a|
        ActiveBankAccount.new(a)
      end if attrs
    end

    def verification_fields_needed=(attrs)
      @verification_fields_needed = attrs || []
    end

    def account_exists?
      account_id.present?
    end

    def account_active
      account_exists? && verification_disabled_reason.nil?
    end

    def disabled_reason
      if verification_disabled_reason.nil?
        ''
      else
        verification_disabled_reason.split('_').join(' ')
      end
    end

    def update_until
      verification_due_by.try { |v| DateTime.parse(v).to_date }
    end

    def last_charge
      last_charge_created_at.try { |v| DateTime.parse(v).to_date }
    end

    def fields_needed
      verification_fields_needed
        .map { |f| f.split(/[\._]/).map(&:capitalize).join(' ') }
        .join(', ')
    end
  end

  # Representation of a {Charge} object in the Payment Service.
  class Charge < StripeHash
    include Comparable
    def <=>(other)
      charge_id <=> other.charge_id
    end

    # use capture to set whether or not to immediately capture the Charge,
    # use captured to check if Charge still uncaptured or has since been
    #   captured
    attr_accessor :reference_charge_id, :charge_id, :created_at, :status,
                  :capture, :captured, :description, :services, :amount_cents,
                  :amount_refunded_cents, :currency, :customer_id,
                  :customer_name, :customer_address, :customer_email,
                  :credit_card_brand, :credit_card_last4, :origin

    # Fetch the list of {Charge}s for the given {Merchant} UUID from the Payment
    #   Service. {Charge} objects are in reverse chronological order according
    #   to their {#created_at} attribute.
    #
    # @todo The complete list of charges might be very long. Therefore, we have
    #   to add a way to paginate the list.
    #
    # @param merchant_id [String] UUID.
    # @return [Array<ShorePayment::Charge>]
    def self.all(merchant_id, locale: 'en')
      connector = MerchantConnector.new(merchant_id, locale: locale)
      connector.get_charges({})['charges']
        .map { |charge_attrs| new(charge_attrs) }
    end

    def customer_address=(attrs)
      @customer_address = CustomerAddress.new(attrs)
    end

    def services=(attrs)
      @services = attrs.map { |a| Service.new(a) }
    end
  end

  # Representation of a {Payment} object in the Payment Service.
  class MerchantPayment < StripeHash
    attr_accessor :id, :meta, :stripe,
                  :stripe_publishable_key, :charge_limit_per_day

    class << self
      def from_payment_service(current_user, profile_id, locale: 'en')
        connector = MerchantConnector.new(profile_id, locale: locale)

        # Fetch Merchant from the Payment Service. Create new Merchant
        #   if it does not exist.
        payment_resp = connector.get_merchant ||
                       connector.create_merchant(current_user)

        new(current_user, payment_resp, locale: locale)
      end

      def collection_from_payment_service(current_user, params, locale: 'en')
        connector = Connector.new(locale: locale)
        payment_resp = connector.get_merchants(params)
        Collection.new(payment_resp) do |response|
          response['merchants'].map { |h| new(current_user, h) }
        end
      end
    end

    def initialize(current_user, attributes, locale: 'en')
      @current_user = current_user
      @locale = locale
      super(attributes)
    end

    def stripe=(attrs)
      @stripe = MerchantStripe.new(attrs)
    end

    def mid
      @id
    end

    def add_bank_account(token)
      MerchantConnector
        .new(@id, locale: @locale)
        .add_bank_account(@current_user, token)
    end

    def create_stripe_account(country)
      MerchantConnector
        .new(@id, locale: @locale)
        .create_stripe_account(@current_user, country)
    end

    def update_stripe_account(stripe_payload)
      MerchantConnector
        .new(@id, locale: @locale)
        .update_stripe_account(@current_user, stripe_payload)
    end

    # Update non-stripe attributes on the current merchant
    #
    # @param params [Hash<String,Object>] JSON serializable dictionary.
    #
    # @return [Hash<String,Object>] JSON respresentation of the +Merchant+.
    # @raise [RuntimeError] Request failed.
    def update_merchant(params)
      MerchantConnector
        .new(@id, locale: @locale)
        .update_merchant(@current_user, params)
    end

    def charges
      Charge.all(mid)
    end

    def supported_countries
      Connector.new(locale: @locale).get_countries
    end

    def bank_account_currencies
      c = stripe.country || 'DE'
      Connector.new(locale: @locale).get_country_bank_account_currencies(c)
    end

    def verification_fields
      c = stripe.country || 'DE'
      Connector.new(locale: @locale).get_country_verification_fields(c)
    end

    def tax_calculations(params)
      Connector.new(locale: @locale).get_tax_calulcations(params)
    end
  end

  # Representation of a {Verification} object in the Payment Service.
  class Verification < StripeHash
    attr_accessor :details, :details_code, :document, :status
  end
end
