module ShorePayment
  #
  class StripeHash
    ATTRIBUTES = [].freeze

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

    def default_attrs
      ATTRIBUTES.map do |attr|
        [attr, nil]
      end.to_h
    end
  end

  # Conversion between day of birth Hash and Date representation
  module StripeDobDate
    ATTRIBUTES = %i(day month year).freeze

    def dob_date
      if @dob && !empty?
        Date.new(@dob.year.to_i, @dob.month.to_i, @dob.day.to_i)
      end
    end

    def dob_date=(new_date)
      new_date = new_date.to_date if new_date.respond_to?(:to_date)
      @dob = DateOfBirth.new(default_attrs) unless @dob
      ATTRIBUTES.each { |a| @dob.send(:"#{a}=", new_date.send(a)) } if new_date
    end

    private

    def empty?
      ATTRIBUTES.any? do |a|
        value = dob.send(:"#{a}")
        value.nil? || value == ''
      end
    end
  end

  # Representation of a {DOB} object in the Organization response
  class DateOfBirth < StripeHash
    ATTRIBUTES = %i(day month year).freeze

    attr_accessor(*ATTRIBUTES)
  end

  # Representation of an {Address} object in the Organization response
  class Address < StripeHash
    ATTRIBUTES = %i(city country line1 line2 postal_code state).freeze

    attr_accessor(*ATTRIBUTES)
  end

  # Representation of an {AdditionalOwner} object in the Organization response
  class AdditionalOwner < StripeHash
    include StripeDobDate

    ATTRIBUTES = %i(first_name last_name dob).freeze

    attr_accessor(*ATTRIBUTES)

    def dob=(attrs)
      @dob ? @dob.update_attributes(attrs) : @dob = DateOfBirth.new(attrs)
    end
  end

  # Representation of an {LegalEntity} object in the Organization response
  class LegalEntity < StripeHash
    include StripeDobDate

    ATTRIBUTES = %i(additional_owners address dob first_name last_name
                    type).freeze

    attr_accessor(*ATTRIBUTES)

    def update_attributes(attrs = {})
      super
      @additional_owners = '' if @type == 'individual' || number_of_owners == 1
    end

    def address=(attrs)
      if @address
        @address.update_attributes(attrs)
      else
        @address = Address.new(attrs)
      end
    end

    def additional_owners=(attrs)
      # We alway build a new array of additional owners, because there is no
      #   such thing as editing a single additional owner.
      # Setting additional_owners to an empty string means that stripe API
      #   should delete all additional owners
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
      @dob ? @dob.update_attributes(attrs) : @dob = DateOfBirth.new(attrs)
    end

    def clear_additional_owners!
      @additional_owners = ''
    end

    def number_of_owners
      return 1 unless additional_owners
      additional_owners.length + 1
    end

    def as_hash
      JSON.parse(to_json)
    end
  end

  # Representation of an {ActiveBankAccount} object in the Organization response
  class ActiveBankAccount < StripeHash
    ATTRIBUTES = %i(bank_name currency created_at
                    last4 name status).freeze

    attr_accessor(*ATTRIBUTES)

    def date_created
      Date.parse(created_at) unless created_at.nil?
    end
  end

  # Representation of a {Stripe} object in the Organization response
  class Stripe < StripeHash
    ATTRIBUTES = %i(account_id active_bank_accounts charges_count
                    last_charge_created_at legal_entity meta publishable_key
                    verification_disabled_reason verification_due_by
                    verfication_fields_needed).freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attrs = nil)
      attrs ||= { legal_entity: { address: {} } }
      update_attributes(attrs)
    end

    def legal_entity=(attrs)
      if @legal_entity
        @legal_entity.update_attributes(attrs)
      else
        @legal_entity = LegalEntity.new(attrs)
      end
    end

    def active_bank_accounts=(attrs)
      @active_bank_accounts = []

      @active_bank_accounts = attrs.map do |a|
        ActiveBankAccount.new(a)
      end if attrs
    end

    def verification_fields_needed=(attrs)
      @verification_fields_needed = []

      @verification_fields_needed = attrs.map do |a|
        a
      end if attrs
    end

    def account_exists?
      !account_id.nil?
    end

    def account_active
      !account_id.nil? && verification_disabled_reason.nil? ? 'yes' : 'no'
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
