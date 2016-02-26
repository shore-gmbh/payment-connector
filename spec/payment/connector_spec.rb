require 'spec_helper'

describe ShorePayment::Connector do
  let(:oid)     { SecureRandom.uuid }
  let(:fake_id) { SecureRandom.uuid }
  let(:fake_token) { 'btok_7pOCL22R2RLUC8' }

  describe '#get_organizations' do
    it 'sends a GET request to /v1/organizations/' do
      params = hash_including(
        basic_auth: an_instance_of(Hash),
        query: { filter: { state: 'disabled' } }
      )

      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with('/v1/organizations/', params)
        .and_return(mock_success('{"organizations":[]}'))

      expect(subject.get_organizations(filter: { state: 'disabled' })).to eq([])
    end

    it 'returns nil if the service responds with code 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_not_found)

      expect(subject.get_organizations({})).to be_nil
    end

    it 'raises an error if the service responds with code != 200 and != 404' do
      expect(ShorePayment::HttpRetriever).to receive(:get)
        .with(any_args)
        .and_return(mock_server_error)

      expect do
        subject.get_organizations({})
      end.to raise_error(RuntimeError)
    end
  end
end
