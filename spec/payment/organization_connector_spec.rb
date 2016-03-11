require 'spec_helper'

describe ShorePayment::OrganizationConnector do
  let(:oid)     { SecureRandom.uuid }
  let(:fake_id) { SecureRandom.uuid }
  let(:fake_token) { 'btok_7pOCL22R2RLUC8' }

  subject { described_class.new(oid) }
  describe '#get_organization' do
    it 'sends a GET request to /v1/organizations/:oid/' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}", auth_mock)
        .and_return(mock_success('{"organization":{}}'))

      expect(subject.get_organization).to eq({})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_organization).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_organization
      end.to raise_error(RuntimeError)
    end
  end

  describe '#create_organization' do
    it 'sends a POST request to /v1/organizations/:oid' do
      options = hash_including(
        query: { meta: { 'foo' => 'bar' } },
        basic_auth: an_instance_of(Hash)
      )
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}", options)
        .and_return(mock_created('{}'))

      expect(subject.create_organization('foo' => 'bar')).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect { subject.create_organization(oid) }
        .to raise_error(RuntimeError)
    end
  end

  describe '#get_charges' do
    let(:page) { 2 }
    let(:per_page) { 10 }
    it 'sends a GET request to /v1/:oid/charges' do
      query_hash = hash_including(page: page, per_page: per_page)
      options = hash_including(query: query_hash,
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}/charges", options)
        .and_return(mock_success('{"charges":[]}'))

      expect(subject.get_charges(page: page, per_page: per_page)).to eq([])
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
    it 'sends a GET request to /v1/:oid/charges/:id' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}/charges/#{fake_id}", auth_mock)
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

  describe '#create_charge' do
    let(:charge_params) do
      {
        credit_card_token: 'credit_card_token',
        amount_cents: '100',
        currency: 'eur',
        description: 'description',
        statement_descriptor: 'your company'
      }
    end

    it 'sends a POST request to /v1/:oid/charges/' do
      options = hash_including(query: an_instance_of(Hash),
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}/charges", options)
        .and_return(mock_success('{"created_charge":{}}'))

      expect(subject.create_charge(charge_params)).to eq('created_charge' => {})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.create_charge(charge_params)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_charge(charge_params)
      end.to raise_error(RuntimeError)
    end

    describe 'parameter validations' do
      it 'fails if credit_card_token is missing' do
        expect do
          subject.create_charge(charge_params.except(:credit_card_token))
        end.to raise_error(RuntimeError)
      end

      it 'fails if amount_cents is missing' do
        expect do
          subject.create_charge(charge_params.except(:amount_cents))
        end.to raise_error(RuntimeError)
      end

      it 'fails if currency is missing' do
        expect do
          subject.create_charge(charge_params.except(:currency))
        end.to raise_error(RuntimeError)
      end

      it 'fails if parameter is unknown' do
        expect do
          subject.create_charge(charge_params.merge(foo: 'bar'))
        end.to raise_error(RuntimeError)
      end
    end
  end

  describe '#create_refund' do
    it 'sends a POST request to /v1/:oid/charges/:charge_id/refund' do
      charge_id = 'charge_id'
      options = hash_including(query: an_instance_of(Hash),
                               basic_auth: an_instance_of(Hash))

      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}/charges/#{charge_id}/refund", options)
        .and_return(mock_success('{}'))

      expect(subject.create_refund(charge_id: charge_id,
                                   amount_refunded_cents: 3)).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.create_refund(charge_id: 1, amount_refunded_cents: 3)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#add_bank_account' do
    it 'sends a POST request to /v1/:oid/bank_accounts' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}/bank_accounts", options)
        .and_return(mock_created('{}'))

      expect(subject.add_bank_account(fake_token)).to eq({})
    end

    it 'raises an error if the service responds with code != 200..299' do
      expect(ShorePayment::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.add_bank_account(fake_token)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#add_stripe_account_to_organization' do
    it 'sends a PUT request to /v1/:oid/stripe' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/organizations/#{oid}/stripe", options)
        .and_return(mock_created('{}'))

      expect(subject.add_stripe_account(fake_token)).to eq({})
    end

    it 'raises an error if the service responds with code != [200..299, 404]' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.add_stripe_account(fake_token)
      end.to raise_error(RuntimeError)
    end

    it 'raises an error with details if the service responds with code 422' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_unprocessable_entity_error('{"error":"wrong"}'))

      expect do
        subject.add_stripe_account(fake_token)
      end.to raise_error(/wrong/)
    end
  end

  describe '#get_dispute' do
    it 'sends a GET request to /v1/disputes/:id' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/disputes/#{fake_id}", auth_mock)
        .and_return(mock_success('{"dispute":{}}'))

      expect(subject.get_dispute(fake_id)).to eq({})
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_dispute(fake_id)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_dispute(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#update_dispute' do
    it 'sends a PUT request to /v1/disputes/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/disputes/#{fake_id}", options)
        .and_return(mock_created('{}'))

      expect(
        subject.update_dispute(fake_id, evidence: {})
      ).to eq({})
    end

    it 'raises an error if the service responds with code != [200..299, 404]' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_dispute(dispute_id: fake_id, evidence: {})
      end.to raise_error(RuntimeError)
    end

    it 'raises an error with details if the service responds with code 422' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_unprocessable_entity_error('{"error":"wrong"}'))

      expect do
        subject.update_dispute(dispute_id: fake_id, evidence: {})
      end.to raise_error(/wrong/)
    end
  end
end
