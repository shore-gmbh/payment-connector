require 'spec_helper'

describe ShorePayment::MerchantConnector do
  let(:mid)     { SecureRandom.uuid }
  let(:fake_id) { SecureRandom.uuid }
  let(:fake_token) { 'btok_7pOCL22R2RLUC8' }
  let(:current_user) { 'user:123' }
  let(:query_mock) { hash_including(current_user: current_user) }

  subject { described_class.new(mid) }
  describe '#get_merchant' do
    it 'sends a GET request to /v1/merchants/:mid/' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/merchants/#{mid}", auth_mock)
        .and_return(mock_success('{"merchant":{}}'))

      expect(subject.get_merchant).to eq({})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_merchant).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_merchant
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_merchant' do
    it 'sends a POST request to /v1/merchants/:mid' do
      options = hash_including(
        query: { current_user: current_user, meta: { 'foo' => 'bar' } },
        basic_auth: an_instance_of(Hash)
      )
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/merchants/#{mid}", options)
        .and_return(mock_created('{}'))

      expect(subject.create_merchant(current_user, 'foo' => 'bar')).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect { subject.create_merchant(current_user, mid) }
        .to raise_error(RuntimeError)
    end
  end

  describe '#update_merchant' do
    it 'sends a PUT request to /v1/merchants/:mid' do
      options = hash_including(
        query: { current_user: current_user, charge_limit_per_day: 100 },
        basic_auth: an_instance_of(Hash)
      )

      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/merchants/#{mid}", options)
        .and_return(mock_success('{}'))

      expect(subject.update_merchant(current_user, charge_limit_per_day: 100))
        .to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_merchant(current_user, charge_limit_per_day: 100)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_charges' do
    let(:page) { 2 }
    let(:per_page) { 10 }
    it 'sends a GET request to /v1/:mid/charges' do
      query_hash = hash_including(page: page, per_page: per_page)
      options = hash_including(query: query_hash,
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/merchants/#{mid}/charges", options)
        .and_return(mock_success('{"charges":[]}'))

      charges = subject.get_charges(page: page, per_page: per_page)['charges']
      expect(charges).to eq([])
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_charges(page: page, per_page: per_page)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_charges(page: page, per_page: per_page)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_charge' do
    it 'sends a GET request to /v1/:mid/charges/:id' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/merchants/#{mid}/charges/#{fake_id}", auth_mock)
        .and_return(mock_success('{"charge":{}}'))

      expect(subject.get_charge(fake_id)).to eq({})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_charge(fake_id)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_charge(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_charge_for_appointment' do
    it 'sends a GET request to /v1/:mid/charges/for_appointment/' \
      ':appointment_id' do
      path = "/v1/merchants/#{mid}/charges/for_appointment/#{fake_id}"
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(path, auth_mock).and_return(mock_success('{"charge":{}}'))

      expect(subject.get_charge_for_appointment(fake_id)).to eq({})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_charge_for_appointment(fake_id)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_charge_for_appointment(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_charge' do
    let(:charge_params) do
      {
        credit_card_token: 'credit_card_token',
        amount_cents: '100',
        currency: 'eur',
        description: 'description',
        statement_descriptor: 'your company',
        capture: 'true'
      }
    end

    it 'sends a POST request to /v1/:mid/charges/' do
      options = hash_including(query: query_mock,
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/merchants/#{mid}/charges", options)
        .and_return(mock_success('{"created_charge":{}}'))

      expect(subject.create_charge(current_user, charge_params))
        .to eq('created_charge' => {})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.create_charge(current_user, charge_params)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_charge(current_user, charge_params)
      end.to raise_error(RuntimeError)
    end

    describe 'parameter validations' do
      it 'fails if credit_card_token is missing' do
        expect do
          subject.create_charge(current_user,
                                charge_params.except(:credit_card_token))
        end.to raise_error(RuntimeError)
      end

      it 'fails if amount_cents is missing' do
        expect do
          subject.create_charge(current_user,
                                charge_params.except(:amount_cents))
        end.to raise_error(RuntimeError)
      end

      it 'fails if currency is missing' do
        expect do
          subject.create_charge(current_user, charge_params.except(:currency))
        end.to raise_error(RuntimeError)
      end

      it 'fails if parameter is unknown' do
        expect do
          subject.create_charge(current_user, charge_params.merge(foo: 'bar'))
        end.to raise_error(RuntimeError)
      end
    end
  end

  describe '#create_refund' do
    it 'sends a POST request to /v1/:mid/charges/:charge_id/refund' do
      charge_id = 'charge_id'
      amount_refunded = 3
      query = {
        current_user: current_user,
        amount_refunded_cents: amount_refunded
      }
      options = hash_including(query: query, basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/merchants/#{mid}/charges/#{charge_id}/refund", options)
        .and_return(mock_success('{}'))

      result = subject.create_refund(current_user: current_user,
                                     charge_id: charge_id,
                                     amount_refunded_cents: amount_refunded)
      expect(result).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_refund(current_user: current_user,
                              charge_id: 1,
                              amount_refunded_cents: 3)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#update_charge' do
    let(:charge_id) { 'charge_id' }
    let(:update_params) do
      {
        appointment_id: '1',
        customer_id: '2',
        foo: 'bar'
      }
    end

    it 'sends a PUT request to /v1/:mid/charges/:charge_id' do
      options = hash_including(query: query_mock,
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/merchants/#{mid}/charges/#{charge_id}", options)
        .and_return(mock_success('{"updated_charge":{}}'))

      expect(subject.update_charge(current_user, charge_id, update_params))
        .to eq('updated_charge' => {})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_not_found)

      expect(
        subject.update_charge(current_user, charge_id, update_params)
      ).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_charge(current_user, charge_id, update_params)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#capture_charge' do
    let(:charge_id) { 'charge_id' }

    it 'sends a POST request to /v1/:mid/charges/:charge_id/capture' do
      options = hash_including(query: query_mock,
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/merchants/#{mid}/charges/#{charge_id}/capture", options)
        .and_return(mock_success('{"captured_charge":{}}'))

      expect(subject.capture_charge(current_user, charge_id))
        .to eq('captured_charge' => {})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_not_found)

      expect(
        subject.capture_charge(current_user, charge_id)
      ).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.capture_charge(current_user, charge_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#add_bank_account' do
    it 'sends a POST request to /v1/:mid/bank_accounts' do
      options = hash_including(basic_auth: an_instance_of(Hash),
                               query: query_mock)
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/merchants/#{mid}/bank_accounts", options)
        .and_return(mock_created('{}'))

      expect(subject.add_bank_account(current_user, fake_token)).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.add_bank_account(current_user, fake_token)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#add_stripe_account_to_merchant' do
    let(:legal_entity_fields) { { legal_entity: double('Legal Entity') } }
    it 'sends a PUT request to /v1/:mid/stripe' do
      options = hash_including(basic_auth: an_instance_of(Hash),
                               query: query_mock)
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/merchants/#{mid}/stripe", options)
        .and_return(mock_created('{}'))

      expect(subject.add_stripe_account(current_user,
                                        legal_entity_fields)).to eq({})
    end

    it 'raises an error if the service responds with code != [200..299, 404]' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.add_stripe_account(current_user, legal_entity_fields)
      end.to raise_error(RuntimeError)
    end

    it 'raises an error with details if the service responds with code 422' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_unprocessable_entity_error('{"error":"wrong"}'))

      expect do
        subject.add_stripe_account(current_user, legal_entity_fields)
      end.to raise_error(/wrong/)
    end
  end
end
