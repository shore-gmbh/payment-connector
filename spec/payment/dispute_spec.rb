require 'spec_helper'

describe ShorePayment::Dispute do
  let(:mid) { SecureRandom.uuid }
  let(:dispute) do
    ShorePayment::Dispute.new(
      payment_service_dispute_response(mid, {})['dispute']
    )
  end

  describe 'attributes' do
    it { expect(dispute).to respond_to(:id) }
    it { expect(dispute).to respond_to(:status) }
    it { expect(dispute).to respond_to(:reason) }
    it { expect(dispute).to respond_to(:amount_cents) }
    it { expect(dispute).to respond_to(:currency) }
    it { expect(dispute).to respond_to(:created_at) }
    it { expect(dispute).to respond_to(:merchant_id) }
    it { expect(dispute).to respond_to(:due_by) }
    it { expect(dispute).to respond_to(:has_evidence) }
    it { expect(dispute).to respond_to(:past_due) }
    it { expect(dispute).to respond_to(:submission_count) }
    it { expect(dispute).to respond_to(:evidence) }
    it { expect(dispute).to respond_to(:charge) }
  end

  describe 'methods' do
    it { expect(dispute).to respond_to(:update) }
  end

  context '#charge' do
    it 'returns with a Charge object' do
      expect(dispute.charge).to be_a(ShorePayment::Charge)
      expect(dispute.charge.charge_id).to eq('ch_17kyvuBJMmId6xqIDWIRAimq')
    end
  end

  context '#evidence' do
    let(:evidence) { dispute.evidence }

    describe 'attributes' do
      it { expect(evidence).to respond_to(:product_description) }
      it { expect(evidence).to respond_to(:customer_name) }
      it { expect(evidence).to respond_to(:customer_email_address) }
      it { expect(evidence).to respond_to(:billing_address) }
      it { expect(evidence).to respond_to(:receipt) }
      it { expect(evidence).to respond_to(:customer_signature) }
      it { expect(evidence).to respond_to(:customer_communication) }
      it { expect(evidence).to respond_to(:uncategorized_file) }
      it { expect(evidence).to respond_to(:uncategorized_text) }
      it { expect(evidence).to respond_to(:service_date) }
      it { expect(evidence).to respond_to(:service_documentation) }
      it { expect(evidence).to respond_to(:shipping_address) }
      it { expect(evidence).to respond_to(:shipping_carrier) }
      it { expect(evidence).to respond_to(:shipping_date) }
      it { expect(evidence).to respond_to(:shipping_documentation) }
      it { expect(evidence).to respond_to(:shipping_tracking_number) }
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
