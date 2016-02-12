require 'spec_helper'

describe TSS::OrganizationConnector do
  let(:oid)     { SecureRandom.uuid }
  let(:fake_id) { SecureRandom.uuid }
  let(:fake_token) { 'btok_7pOCL22R2RLUC8' }

  subject { described_class.new(oid) }
  describe '#get_organization' do
    it 'sends a GET request to /v1/organizations/:oid/' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}", auth_mock)
        .and_return(mock_success('{"organization":{}}'))

      expect(subject.get_organization).to eq({})
    end

    it 'returns nil if the TSS responds with code 404' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_organization).to be_nil
    end

    it 'raises an error if the TSS responds with code != 200 and != 404' do
      expect(TSS::HttpRetriever).to receive(:get)
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
      expect(TSS::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}", options)
        .and_return(mock_created('{}'))

      expect(subject.create_organization('foo' => 'bar')).to eq({})
    end

    it 'raises an error if the TSS responds with code != 201' do
      expect(TSS::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect { subject.create_organization(oid) }
        .to raise_error(RuntimeError)
    end
  end

  describe '#get_transactions' do
    it 'sends a GET request to /v1/:oid/transactions' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}/transactions", auth_mock)
        .and_return(mock_success('{"transactions":[]}'))

      expect(subject.get_transactions).to eq([])
    end

    it 'returns nil if the TSS responds with code 404' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_transactions).to be_nil
    end

    it 'raises an error if the TSS responds with code != 200 and != 404' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_transactions
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_transaction' do
    it 'sends a GET request to /v1/:oid/transactions/:id' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with("/v1/organizations/#{oid}/transactions/#{fake_id}", auth_mock)
        .and_return(mock_success('{"transaction":{}}'))

      expect(subject.get_transaction(fake_id)).to eq({})
    end

    it 'returns nil if the TSS responds with code 404' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_transaction(fake_id)).to be_nil
    end

    it 'raises an error if the TSS responds with code != 200 and != 404' do
      expect(TSS::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_transaction(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#add_bank_account' do
    it 'sends a POST request to /v1/:oid/bank_accounts' do
      options = hash_including(basic_auth: an_instance_of(Hash))
      expect(TSS::HttpRetriever).to receive(:post)
        .with("/v1/organizations/#{oid}/bank_accounts", options)
        .and_return(mock_created('{}'))

      expect(subject.add_bank_account(fake_token)).to eq({})
    end

    it 'raises an error if the TSS responds with code != 201' do
      expect(TSS::HttpRetriever).to receive(:post)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.add_bank_account(fake_token)
      end.to raise_error(RuntimeError)
    end
  end
end
