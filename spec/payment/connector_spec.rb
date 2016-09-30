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
        query: { locale: 'en', filter: { state: 'disabled' } }
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
        query: { locale: 'en' }
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
    let(:query_mock) do
      hash_including(locale: 'en', current_user: current_user)
    end

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

  describe '#get_countries' do
    it 'sends a GET request to /v1/countries/' do
      params = hash_including(
        basic_auth: an_instance_of(Hash),
        query: { locale: 'en' }
      )

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with('/v1/countries/', params)
        .and_return(mock_success('{"countries":["RO", "DE"]}'))

      expect(subject.get_countries).to eq(%w(RO DE))
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_countries({})
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_country_verification_fields' do
    it 'sends a GET request to /v1/countries/:id/verification_fields' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/countries/#{fake_id}/verification_fields", auth_mock)
        .and_return(
          mock_success('{"verification_fields":["foo", "bar"]}')
        )

      expect(subject.get_country_verification_fields(fake_id)).to \
        eq(%w(foo bar))
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_country_verification_fields(fake_id)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_country_verification_fields(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_bank_account_currencies' do
    it 'sends a GET request to /v1/countries/:id/bank_account_currencies' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with("/v1/countries/#{fake_id}/bank_account_currencies", auth_mock)
        .and_return(mock_success('{"usd": ["US"]}'))

      expect(subject.get_country_bank_account_currencies(fake_id)).to \
        eq('usd' => ['US'])
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_country_bank_account_currencies(fake_id)).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_country_bank_account_currencies(fake_id)
      end.to raise_error(RuntimeError)
    end
  end

  describe '#get_tax_calculations' do
    let(:tax_response) do
      {
        'total_net_cents' => 21_212,
        'total_cents' => 25_000,
        'taxes' => [
          {
            'name' => 'Value Added Tax 20%',
            'taxes_cents' => 3788
          }
        ]
      }
    end

    let(:query_params) do
      {
        'services' => [
          {
            'service_price_cents' => 25_000,
            'tax_category' => { 'name' => 'Value Added Tax 20%' }
          }
        ]
      }
    end

    it 'sends a GET request to /v1/tax_calculations/' do
      params = hash_including(
        query: hash_including(query_params.merge(locale: 'en'))
      )

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with('/v1/tax_calculations/', params)
        .and_return(mock_success(tax_response.to_json))

      response = subject.get_tax_calculations(query_params)
      expect(response['taxes'].count).to eq(1)
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_tax_calculations({})
      end.to raise_error(RuntimeError)
    end
  end
end
