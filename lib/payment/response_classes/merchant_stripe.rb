module ShorePayment
  # Conversion between day of birth's Hash and Date representation
  module DobConvertible
    def dob_date
      if @dob && dob_present?
        Date.new(@dob.year.to_i, @dob.month.to_i, @dob.day.to_i)
      end
    end

    def dob_date=(new_date)
      date = new_date.to_date
      @dob = DateOfBirth.new(
        year: date.year,
        month: date.month,
        day: date.day
      ) if date
    end

    private

    def dob_present?
      @dob.year.present? && @dob.month.present? && @dob.day.present?
    end
  end

  # Representation of a {DOB} object in the Organization response
  class DateOfBirth < StripeHash
    attr_accessor :day, :month, :year
  end

  # Representation of an {Address} object in the Organization response
  class Address < StripeHash
    attr_accessor :city, :country, :line1, :line2, :postal_code, :state
  end

  # Representation of an {AdditionalOwner} object in the Organization response
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

  # Representation of a {LegalEntity} object in the Organization response
  class LegalEntity < StripeHash
    include DobConvertible

    attr_accessor :additional_owners, :address, :business_name,
                  :business_tax_id, :business_tax_id_provided, :dob,
                  :first_name, :last_name, :type, :verification

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

    def as_hash
      JSON.parse(to_json)
    end
  end

  # Representation of an {ActiveBankAccount} object in the Organization response
  class ActiveBankAccount < StripeHash
    attr_accessor :bank_name, :currency, :created_at, :last4, :name, :status

    def date_created
      created_at.try { |d| Date.parse(d) }
    end
  end

  # Representation of a {Stripe} object in the Organization response
  class MerchantStripe < StripeHash
    attr_accessor :account_id, :active_bank_accounts, :charges_count,
                  :last_charge_created_at, :legal_entity, :meta,
                  :publishable_key, :verification_disabled_reason,
                  :verification_due_by, :verification_fields_needed,
                  :transfers_enabled, :charges_enabled

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

    attr_accessor :charge_id, :status, :amount_cents, :currency,
                  :customer_name, :credit_card_brand, :created_at

    # Fetch the list of {Charge}s for the given {Merchant} UUID from the Payment
    #   Service. {Charge} objects are in reverse chronological order according
    #   to their {#created_at} attribute.
    #
    # @todo The complete list of charges might be very long. Therefore, we have
    #   to add a way to paginate the list.
    #
    # @param merchant_id [String] UUID.
    # @return [Array<ShorePayment::Charge>]
    def self.all(merchant_id)
      connector = OrganizationConnector.new(merchant_id)
      connector.get_charges({}).map { |charge_attrs| new(charge_attrs) }
    end
  end

  # Representation of a {Payment} object in the Payment Service.
  class MerchantPayment < StripeHash
    attr_accessor :id, :meta, :stripe, :stripe_publishable_key

    class << self
      def from_payment_service(profile_id)
        connector = OrganizationConnector.new(profile_id)

        # Fetch Organization from the Payment Service. Create new Organization
        #   if it does not exist.
        payment_resp = connector.get_organization ||
                       connector.create_organization

        new(payment_resp)
      end

      def collection_from_payment_service(params)
        connector = Connector.new
        payment_resp = connector.get_organizations(params)
        Collection.new(payment_resp) do |response|
          response['organizations'].map { |h| new(h) }
        end
      end
    end

    def stripe=(attrs)
      @stripe = MerchantStripe.new(attrs)
    end

    def oid
      @id
    end

    def add_bank_account(token)
      OrganizationConnector.new(@id).add_bank_account(token)
    end

    def add_stripe_account(stripe_payload)
      OrganizationConnector.new(@id).add_stripe_account(stripe_payload)
    end

    def charges
      Charge.all(oid)
    end
  end

  # Representation of a {Verification} object in the Payment Service.
  class Verification < StripeHash
    attr_accessor :details, :details_code, :document, :status
  end
end
