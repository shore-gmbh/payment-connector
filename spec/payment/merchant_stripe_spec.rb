require 'spec_helper'

describe ShorePayment::MerchantStripe do
  let(:mid) { SecureRandom.uuid }

  subject do
    described_class.new(
      payment_service_merchant_response(mid, {})['stripe']
    )
  end

  describe 'attributes' do
    it { is_expected.to respond_to(:account_id) }
    it { is_expected.to respond_to(:active_bank_accounts) }
    it { is_expected.to respond_to(:charges_count) }
    it { is_expected.to respond_to(:last_charge_created_at) }
    it { is_expected.to respond_to(:legal_entity) }
    it { is_expected.to respond_to(:meta) }
    it { is_expected.to respond_to(:publishable_key) }
    it { is_expected.to respond_to(:verification_disabled_reason) }
    it { is_expected.to respond_to(:verification_due_by) }
    it { is_expected.to respond_to(:verification_fields_needed) }
    it { is_expected.to respond_to(:account_active) }
    it { is_expected.to respond_to(:disabled_reason) }
    it { is_expected.to respond_to(:update_until) }
    it { is_expected.to respond_to(:last_charge) }
    it { is_expected.to respond_to(:fields_needed) }
    it { is_expected.to respond_to(:transfers_enabled) }
    it { is_expected.to respond_to(:charges_enabled) }
    it { is_expected.to respond_to(:country) }
  end

  context '#account_active' do
    it 'should return true if no verification_disabled_reason present' do
      active_account = described_class.new(
        payment_service_merchant_response(
          mid,
          'stripe' => {
            'account_id' => '1',
            'verification_disabled_reason' => nil
          }
        )['stripe']
      )
      expect(active_account.account_active).to be_truthy
    end

    it 'should return false if any verification_disabled_reason present' do
      expect(subject.account_active).to be_falsey
    end

    it 'should return false if created from an empty hash' do
      empty_account = ShorePayment::MerchantStripe.new
      expect(empty_account.account_active).to be_falsey
    end
  end

  context '#account_exists?' do
    it 'should return true if account_id has value' do
      expect(subject.account_exists?).to eq(true)
    end

    it 'should return false if created from an empty hash' do
      empty_account = ShorePayment::MerchantStripe.new
      expect(empty_account.account_exists?).to eq(false)
    end
  end

  context '#fields_needed' do
    it 'should return a String with list of fields' do
      expect(subject.fields_needed).to include('Legal Entity Dob Month,')
    end
  end

  context '#last_charge' do
    it 'should return nil if there is no charge' do
      expect(subject.last_charge).to be_nil
    end
  end

  context '#disabled_reason' do
    it 'should return a String with readable reason' do
      expect(subject.disabled_reason).to eq('fields needed')
    end
  end

  context '#update_until' do
    it 'should return a Date' do
      expect(subject.update_until).to eq(Date.new(2016, 04, 03))
    end
  end

  describe '#legal_entity' do
    let(:legal_entity) { subject.legal_entity }

    describe 'attributes' do
      it { expect(legal_entity).to respond_to(:additional_owners) }
      it { expect(legal_entity).to respond_to(:business_name) }
      it { expect(legal_entity).to respond_to(:business_tax_id) }
      it { expect(legal_entity).to respond_to(:business_tax_id_provided) }
      it { expect(legal_entity).to respond_to(:dob) }
      it { expect(legal_entity).to respond_to(:dob_date) }
      it { expect(legal_entity).to respond_to(:first_name) }
      it { expect(legal_entity).to respond_to(:last_name) }
      it { expect(legal_entity).to respond_to(:personal_id_number) }
      it { expect(legal_entity).to respond_to(:personal_id_number_provided) }
      it { expect(legal_entity).to respond_to(:ssn_last_4) }
      it { expect(legal_entity).to respond_to(:ssn_last_4_provided) }
      it { expect(legal_entity).to respond_to(:type) }
      it { expect(legal_entity).to respond_to(:verification) }
    end

    it 'has the proper Class' do
      expect(legal_entity).to be_a(ShorePayment::LegalEntity)
    end

    context '#dob' do
      describe 'attributes' do
        it { expect(legal_entity.dob).to respond_to(:day) }
        it { expect(legal_entity.dob).to respond_to(:month) }
        it { expect(legal_entity.dob).to respond_to(:year) }
      end

      it 'has the proper Class' do
        expect(legal_entity.dob).to be_a(ShorePayment::DateOfBirth)
      end

      it 'updates the attributes' do
        legal_entity.dob = { year: 1985, month: 11, day: 3 }
        expect(legal_entity.dob.year).to eq(1985)
        expect(legal_entity.dob.month).to eq(11)
        expect(legal_entity.dob.day).to eq(3)
      end
    end

    context '#dob_date' do
      it 'converts dob attributes to date' do
        expect(legal_entity.dob_date).to eq(Date.new(1970, 2, 3))
      end

      it 'should update the dob attributes from a Date' do
        legal_entity.dob_date = Date.new(2015, 11, 22)
        expect(legal_entity.dob.year).to eq(2015)
        expect(legal_entity.dob.month).to eq(11)
        expect(legal_entity.dob.day).to eq(22)
      end

      it 'should update the dob attributes from a String' do
        legal_entity.dob_date = '2015-11-21'
        expect(legal_entity.dob.year).to eq(2015)
        expect(legal_entity.dob.month).to eq(11)
        expect(legal_entity.dob.day).to eq(21)
      end

      it 'should return nil when the dob attributes are empty' do
        legal_entity.dob.year = nil
        legal_entity.dob.month = nil
        legal_entity.dob.day = nil
        expect(legal_entity.dob_date).to be_nil

        legal_entity.dob.year = ''
        legal_entity.dob.month = ''
        legal_entity.dob.day = ''
        expect(legal_entity.dob_date).to be_nil

        legal_entity.dob.year = 2015
        legal_entity.dob.month = nil
        legal_entity.dob.day = nil
        expect(legal_entity.dob_date).to be_nil
      end

      it 'returns nil if the dob_date is invalid' do
        expect do
          legal_entity.dob_date = 'invalid'
        end.not_to change(legal_entity, :dob)
      end
    end

    context '#address' do
      before do
        legal_entity.address = {
          city: 'RandomCity',
          country: 'RandomCountry',
          line1: 'RandomLine1',
          line2: 'RandomLine2',
          postal_code: 'RandomPostalCode',
          state: 'RandomState'
        }
      end

      describe 'attributes' do
        it { expect(legal_entity.address).to respond_to(:city) }
        it { expect(legal_entity.address).to respond_to(:country) }
        it { expect(legal_entity.address).to respond_to(:line1) }
        it { expect(legal_entity.address).to respond_to(:line2) }
        it { expect(legal_entity.address).to respond_to(:postal_code) }
        it { expect(legal_entity.address).to respond_to(:state) }
      end

      it 'has the proper Class' do
        expect(legal_entity.address).to be_a(ShorePayment::Address)
      end

      it 'updates the attributes' do
        expect(legal_entity.address.city).to eq('RandomCity')
        expect(legal_entity.address.country).to eq('RandomCountry')
        expect(legal_entity.address.line1).to eq('RandomLine1')
        expect(legal_entity.address.line2).to eq('RandomLine2')
        expect(legal_entity.address.postal_code).to eq('RandomPostalCode')
        expect(legal_entity.address.state).to eq('RandomState')
      end
    end

    context '#additional_owners' do
      let(:first_additional_owner) do
        subject.legal_entity.additional_owners.first
      end

      describe 'attributes' do
        it { expect(first_additional_owner).to respond_to(:address) }
        it { expect(first_additional_owner).to respond_to(:dob) }
        it { expect(first_additional_owner).to respond_to(:dob_date) }
        it { expect(first_additional_owner).to respond_to(:first_name) }
        it { expect(first_additional_owner).to respond_to(:last_name) }
        it { expect(first_additional_owner).to respond_to(:verification) }
      end

      it 'has the proper Class' do
        expect(subject.legal_entity.additional_owners).to be_a(Array)
        expect(first_additional_owner).to be_a(ShorePayment::AdditionalOwner)
      end

      it 'should allow to set to a string' do
        subject.legal_entity.additional_owners = ''
        expect(subject.legal_entity.additional_owners).to eq('')
      end

      it '#number_of_owners returns with the count of owners' do
        expect(subject.legal_entity.number_of_owners).to eq(3)
      end

      context '#dob_date' do
        it 'converts dob attributes to date' do
          expect(first_additional_owner.dob_date).to eq(Date.new(1980, 11, 1))
        end

        it 'should update the dob attributes from a Date' do
          first_additional_owner.dob_date = Date.new(2015, 11, 22)
          expect(first_additional_owner.dob.year).to eq(2015)
          expect(first_additional_owner.dob.month).to eq(11)
          expect(first_additional_owner.dob.day).to eq(22)
        end
      end

      it 'updates the attributes with an Array' do
        legal_entity.additional_owners = [
          {
            first_name: 'Fi',
            last_name: 'La',
            dob_date: '1990-02-01'
          },
          {
            first_name: 'Fn',
            last_name: 'Ln',
            dob: { year: 1970, month: 12, day: 15 }
          }
        ]
        expect(legal_entity.additional_owners.first.first_name).to eq('Fi')
        expect(legal_entity.additional_owners.first.dob.month).to eq(2)
        expect(legal_entity.additional_owners.last.last_name).to eq('Ln')
      end

      it 'updates the attributes with a nested Hash' do
        legal_entity.additional_owners = {
          '0' => {
            first_name: 'Fi',
            last_name: 'La',
            dob: { year: 1990, month: 2, day: 1 }
          },
          '1' => {
            first_name: 'Fn',
            last_name: 'Ln',
            dob: { year: 1970, month: 12, day: 15 }
          }
        }
        expect(legal_entity.additional_owners.first.first_name).to eq('Fi')
        expect(legal_entity.additional_owners.first.dob.month).to eq(2)
        expect(legal_entity.additional_owners.last.last_name).to eq('Ln')
      end
    end

    it 'updates all the attributes' do
      legal_entity.update_attributes(
        first_name: 'Fifi',
        dob: { year: '2010', month: '6', day: '4' },
        address:  {
          city: 'RandomCity',
          country: 'RandomCountry',
          line1: 'RandomLine1',
          line2: 'RandomLine2',
          postal_code: 'RandomPostalCode',
          state: 'RandomState'
        },
        additional_owners: {
          '0' => {
            first_name: 'Fi',
            last_name: 'La',
            dob_date: '1990-02-01'
          },
          '1' => {
            first_name: 'Fn',
            last_name: 'Ln',
            dob: { year: 1970, month: 12, day: 15 }
          }
        }
      )
      expect(legal_entity.first_name).to eq('Fifi')
      expect(legal_entity.dob.month).to eq('6')
      expect(legal_entity.additional_owners.first.dob.year).to eq(1990)
      expect(legal_entity.additional_owners.last.last_name).to eq('Ln')
    end

    it 'additional_owners should be an empty string when the type is ' \
       'individual' do
      legal_entity.update_attributes(
        type: 'individual',
        additional_owners: {
          '0' => {
            first_name: 'Fi',
            last_name: 'La',
            dob_date: '1990-02-01'
          },
          '1' => {
            first_name: 'Fn',
            last_name: 'Ln',
            dob: { year: 1970, month: 12, day: 15 }
          }
        }
      )
      expect(legal_entity.number_of_owners).to eq(1)
    end

    context '#verification' do
      describe 'attributes' do
        it { expect(legal_entity.verification).to respond_to(:details) }
        it { expect(legal_entity.verification).to respond_to(:details_code) }
        it { expect(legal_entity.verification).to respond_to(:document) }
        it { expect(legal_entity.verification).to respond_to(:status) }
      end

      it 'has the proper Class' do
        expect(legal_entity.verification).to be_a(ShorePayment::Verification)
      end

      it 'updates the attributes' do
        legal_entity.verification = {
          details: 'detail',
          details_code: 'scan_corrupt',
          document: 'fil_15BZxW2eZvKYlo2CvQbrn9dc',
          status: 'pending'
        }
        verification = legal_entity.verification
        expect(verification.details).to eq('detail')
        expect(verification.details_code).to eq('scan_corrupt')
        expect(verification.document).to eq('fil_15BZxW2eZvKYlo2CvQbrn9dc')
        expect(verification.status).to eq('pending')
      end
    end

    context '#as_hash' do
      subject do
        legal_entity_with_nil_values = {
          'stripe' => {
            'legal_entity' => {
              'first_name' => 'First',
              'last_name' => 'Last',
              'business_name' => nil,
              'address' => {
                'city' => nil,
                'country' => 'DE',
                'line1' => nil,
                'line2' => nil,
                'postal_code' => nil,
                'state' => nil
              },
              'dob' => {
                'year' => nil,
                'month' => nil,
                'day' => nil
              },
              'additional_owners' => [{
                'first_name' => 'Joe',
                'last_name' => nil,
                'dob' => {
                  'year' => nil,
                  'month' => nil,
                  'day' => nil
                }
              }]
            }
          }
        }
        described_class.new(
          payment_service_merchant_response(
            mid,
            legal_entity_with_nil_values)['stripe']
        )
      end

      context 'with nil values paramater' do
        it 'result should contain nil values' do
          hash = legal_entity.as_hash(true)
          expect(hash).to have_key('address')
          expect(hash['address']).to have_key('city')
          expect(hash['address']['city']).to eq(nil)
          expect(hash['address']).to have_key('country')
          expect(hash['address']['country']).to eq('DE')
          expect(hash).to have_key('business_name')
          expect(hash).to have_key('dob')
          expect(hash['dob']).to have_key('year')
          expect(hash['additional_owners'][0]).to have_key('first_name')
          expect(hash['additional_owners'][0]).to have_key('last_name')
          expect(hash['additional_owners'][0]).to have_key('dob')
          expect(hash['additional_owners'][0]['dob']).to have_key('year')
        end
      end

      context 'without nil values' do
        it 'result should contain only attributes with values' do
          hash = legal_entity.as_hash(false)
          expect(hash).to have_key('first_name')
          expect(hash['first_name']).to eq('First')
          expect(hash).to have_key('last_name')
          expect(hash['last_name']).to eq('Last')
          expect(hash).to have_key('address')
          expect(hash['address']).to have_key('country')
          expect(hash['address']['country']).to eq('DE')
          expect(hash).to have_key('additional_owners')
          expect(hash['additional_owners'][0]).to have_key('first_name')
          expect(hash['additional_owners'][0]['first_name']).to eq('Joe')

          expect(hash).not_to have_key('business_name')
          expect(hash).not_to have_key('dob')
          expect(hash['additional_owners'][0]).not_to have_key('last_name')
          expect(hash['additional_owners'][0]).not_to have_key('dob')
        end
      end
    end
  end
end

describe ShorePayment::MerchantPayment do
  let(:mid) { SecureRandom.uuid }
  let(:current_user) { 'admin_user:123' }

  subject do
    described_class.new(
      current_user,
      payment_service_merchant_response(mid, {})
    )
  end

  describe 'attributes' do
    it { is_expected.to respond_to(:id) }
    it { is_expected.to respond_to(:meta) }
    it { is_expected.to respond_to(:mid) }
    it { is_expected.to respond_to(:stripe) }
    it { is_expected.to respond_to(:stripe_publishable_key) }
  end

  describe 'methods' do
    it { is_expected.to respond_to(:add_bank_account) }
    it { is_expected.to respond_to(:create_stripe_account) }
    it { is_expected.to respond_to(:update_stripe_account) }
    it { is_expected.to respond_to(:supported_countries) }
    it { is_expected.to respond_to(:bank_account_currencies) }
    it { is_expected.to respond_to(:verification_fields) }
  end

  context '#charges' do
    let(:charge) do
      ShorePayment::Charge.new(payment_service_charge_response['charge'])
    end

    describe 'attributes' do
      it { expect(charge).to respond_to(:charge_id) }
      it { expect(charge).to respond_to(:created_at) }
      it { expect(charge).to respond_to(:status) }
      it { expect(charge).to respond_to(:captured) }
      it { expect(charge).to respond_to(:description) }
      it { expect(charge).to respond_to(:services) }
      it { expect(charge).to respond_to(:amount_cents) }
      it { expect(charge).to respond_to(:amount_refunded_cents) }
      it { expect(charge).to respond_to(:currency) }
      it { expect(charge).to respond_to(:customer_name) }
      it { expect(charge).to respond_to(:customer_address) }
      it { expect(charge).to respond_to(:customer_email) }
      it { expect(charge).to respond_to(:credit_card_brand) }
      it { expect(charge).to respond_to(:credit_card_last4) }
      it { expect(charge).to respond_to(:origin) }
    end

    context '#customer_address' do
      describe 'attributes' do
        it { expect(charge.customer_address).to respond_to(:city) }
        it { expect(charge.customer_address).to respond_to(:zip) }
        it { expect(charge.customer_address).to respond_to(:street) }
      end
    end

    context '#services' do
      describe 'attributes' do
        it { expect(charge.services.first).to respond_to(:service_name) }
        it { expect(charge.services.first).to respond_to(:service_price_cents) }
      end
    end

    it 'should return a comparable Array of Charges' do
      connector = double('payment connector')

      expect(ShorePayment::MerchantConnector).to(
        receive(:new)
        .with(mid, locale: 'en')
        .and_return(connector).at_least(:once)
      )

      expect(connector).to receive(:get_charges).and_return(
        'charges' => [{ 'charge_id' => '1' }, { 'charge_id' => '2' }]
      ).at_least(:once)

      expect(subject.charges.first.charge_id).to eq('1')
      expect(subject.charges.first > subject.charges.last).to eq(false)
      expect(subject.charges.first == subject.charges.last).to eq(false)
      expect(subject.charges.first < subject.charges.last).to eq(true)
    end
  end
end
