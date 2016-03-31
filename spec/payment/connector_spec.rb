require 'spec_helper'

describe ShorePayment::Connector do
  let(:mid)     { SecureRandom.uuid }
  let(:fake_id) { SecureRandom.uuid }
  let(:fake_token) { 'btok_7pOCL22R2RLUC8' }
  let(:current_user) { 'user:123' }

  describe '#get_merchants' do
    it 'sends a GET request to /v1/merchants/' do
      params = hash_including(
        basic_auth: an_instance_of(Hash),
        query: { filter: { state: 'disabled' } }
      )

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with('/v1/merchants/', params)
        .and_return(mock_success('{"merchants":[]}'))

      answer = subject.get_merchants(filter: { state: 'disabled' })
      expect(answer['merchants']).to eq([])
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_merchants({})).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_merchants({})
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_disputes' do
    it 'sends a GET request to /v1/disputes/' do
      params = hash_including(
        basic_auth: an_instance_of(Hash),
        query: {}
      )

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with('/v1/disputes/', params)
        .and_return(mock_success('{"disputes":[]}'))

      expect(subject.get_disputes['disputes']).to eq([])
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_disputes({})).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_disputes({})
      end.to raise_error(RuntimeError)
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
    let(:query_mock) { hash_including(current_user: current_user) }
    it 'sends a PUT request to /v1/disputes/:id' do
      options = hash_including(basic_auth: an_instance_of(Hash),
                               query: query_mock)

      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with("/v1/disputes/#{fake_id}", options)
        .and_return(mock_created('{}'))

      expect(
        subject.update_dispute(current_user, fake_id, evidence: {})
      ).to eq({})
    end

    it 'raises an error if the service responds with code != [200..299, 404]' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.update_dispute(current_user, dispute_id: fake_id, evidence: {})
      end.to raise_error(RuntimeError)
    end

    it 'raises an error with details if the service responds with code 422' do
      expect(ShorePayment::HttpRetriever).to receive(:put)
        .with(any_args)
        .and_return(mock_unprocessable_entity_error('{"error":"wrong"}'))

      expect do
        subject.update_dispute(current_user, dispute_id: fake_id, evidence: {})
      end.to raise_error(/wrong/)
    end
  end
end
