module ShorePayment
  #
  class StripeHash
    def initialize(attrs = {})
      update_attributes(attrs)
    end

    # Update object with this method. We have to take care updating 'nested'
    #   objects
    def update_attributes(attrs = {})
      attrs.each_pair do |attr, value|
        send(:"#{attr}=", value) if respond_to?(:"#{attr}=")
      end if attrs
    end
  end

  # Conversion between day of birth's Hash and Date representation
  module StripeDobDate
    def dob_date
      if @dob && dob_present?
        Date.new(@dob.year.to_i, @dob.month.to_i, @dob.day.to_i)
      end
    end

    def dob_date=(new_date)
      date = new_date.to_date if new_date.respond_to?(:to_date)
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
    include StripeDobDate

    attr_accessor :first_name, :last_name, :dob

    def dob=(attrs)
      @dob = DateOfBirth.new(attrs)
    end
  end

  # Representation of a {LegalEntity} object in the Organization response
  class LegalEntity < StripeHash
    include StripeDobDate

    attr_accessor :additional_owners, :address, :dob, :first_name, :last_name,
                  :type

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
      @additional_owners = if attrs && attrs.is_a?(String)
                             attrs
                           elsif attrs
                             attrs.map do |a|
                               a = a[1] if a.is_a?(Array)
                               AdditionalOwner.new(a)
                             end
                           end
    end

    def dob=(attrs)
      @dob = DateOfBirth.new(attrs)
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
                  :verification_due_by, :verfication_fields_needed

    def initialize(attrs = nil)
      # Empty stripe object with all the necessery empty nodes
      attrs ||= {
        legal_entity: {
          additional_owners: {},
          address: {}
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
      account_exists? && verification_disabled_reason.nil? ? 'yes' : 'no'
    end

    def disabled_reason
      if verification_disabled_reason.nil?
        ''
      else
        verification_disabled_reason.split('_').join(' ')
      end
    end

    def update_until
      verification_due_by.nil? ? '' : DateTime.parse(verification_due_by)
    end

    def last_charge
      last_charge_created_at.nil? ? '' : DateTime.parse(last_charge_created_at)
    end

    def fields_needed
      verification_fields_needed
        .map { |f| f.split(/[\._]/).map(&:capitalize).join(' ') }
        .join(', ')
    end
  end
end
