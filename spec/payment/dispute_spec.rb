require 'spec_helper'

describe ShorePayment::Dispute do
  let(:oid) { SecureRandom.uuid }
  let(:dispute) do
    described_class.new(payment_service_dispute_response(oid, {})['dispute'])
  end

  describe 'attributes' do
    subject { dispute }

    described_class::SUPPORTED_ATTRIBUTES.each do |attr|
      it { is_expected.to respond_to(attr) }
    end
  end

  describe 'methods' do
    it { expect(dispute).to respond_to(:update) }
  end

  context '#evidence' do
    describe 'attributes' do
      subject { dispute.evidence }

      ShorePayment::Evidence::SUPPORTED_ATTRIBUTES.each do |attr|
        it { is_expected.to respond_to(attr) }
      end
    end
  end

  context '#from_payment_service' do
    subject { ShorePayment::Dispute.from_payment_service('x') }

    before do
      connector = double('payment connector')

      expect(ShorePayment::Connector).to(
        receive(:new).and_return(connector)
      )

      expect(connector).to receive(:get_dispute).and_return(
        id: 'x', status: 'under_review'
      )
    end

    it 'returns with a Dispute object' do
      expect(subject).to be_a(ShorePayment::Dispute)
      expect(subject.id).to eq('x')
      expect(subject.status).to eq('under_review')
    end
  end

  context 'collection_from_payment_service' do
    context 'with no params' do
      let(:params) { {} }
      subject { ShorePayment::Dispute.collection_from_payment_service(params) }

      before do
        params = hash_including(basic_auth: an_instance_of(Hash),
                                query: {}
                               )

        expect(ShorePayment::HttpRetriever).to receive(:get)
          .with('/v1/disputes/', params)
          .and_return(mock_success(payment_service_disputes_response))
      end

      it 'initializes collection' do
        expect(subject.items.size).to eq 2
      end

      it 'has paging parameters' do
        expect(subject.current_page).to eq 1
        expect(subject.per_page).to eq 20
        expect(subject.total_count).to eq 0
        expect(subject.total_pages).to eq 1
      end
    end
  end
end
