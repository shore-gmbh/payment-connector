module ShorePayment
  #
  class StripeHash
    def initialize(attrs = {})
      if attrs
        attrs.each_pair do |attr, value|
          send(:"#{attr}=", value) if respond_to?(:"#{attr}=")
        end
      end
    end
  end

  # Representation of a {DOB} object in the Organization response
  class DateOfBirth < StripeHash
    ATTRIBUTES = %i(day month year).freeze

    attr_accessor(*ATTRIBUTES)

    def date
      Date.new(year.to_i, month.to_i, day.to_i) if year && month && day
    end

    def date=(new_date)
      ATTRIBUTES.each { |a| send(:"#{a}=", new_date.send(a)) } if new_date
    end
  end

  # Representation of an {Address} object in the Organization response
  class Address < StripeHash
    ATTRIBUTES = %i(city country line1 line2 postal_code state).freeze

    attr_accessor(*ATTRIBUTES)
  end

  # Representation of an {AdditionalOwner} object in the Organization response
  class AdditionalOwner < StripeHash
    ATTRIBUTES = %i(first_name last_name dob).freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attrs = {})
      super
      @dob = DateOfBirth.new(attrs['dob'])
    end
  end

  # Representation of an {LegalEntity} object in the Organization response
  class LegalEntity < StripeHash
    ATTRIBUTES = %i(additional_owners address dob first_name last_name
                    type).freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attrs = {})
      super
      @dob = DateOfBirth.new(attrs['dob'])
      @address = Address.new(attrs['address'])
      @additional_owners = nil
      
      @additional_owners = attrs['additional_owners'].map do |a|
        AdditionalOwner.new(a)
      end if attrs['additional_owners']
    end
    
    def clear_additional_owners!
      @additional_owners = ''
    end

    def number_of_owners
      additional_owners.length + 1
    end
  end

  # Representation of an {ActiveBankAccount} object in the Organization response
  class ActiveBankAccount < StripeHash
    ATTRIBUTES = %i(account_holder_name bank_name currency created_at
                    last4 status).freeze

    attr_accessor(*ATTRIBUTES)
  end

  # Representation of a {Stripe} object in the Organization response
  class Stripe < StripeHash
    ATTRIBUTES = %i(account_id active_bank_accounts legal_entity meta
                    publishable_key verification_disabled_reason
                    verification_due_by verfication_fields_needed).freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attrs = {})
      super
      @active_bank_accounts = 
      @legal_entity = LegalEntity.new(attrs['legal_entity'])
      
      @active_bank_accounts = attrs['active_bank_accounts'].map do |a|
        ActiveBankAccount.new(a)
      end if attrs['active_bank_accounts']
    end


    def account_active
      verification_disabled_reason.nil? ? 'yes' : 'no'
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
