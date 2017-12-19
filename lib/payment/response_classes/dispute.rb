module ShorePayment
  # Representation of an {Evidence} object in the Payment Service.
  class Evidence < StripeHash
    attr_accessor :product_description, :customer_name, :customer_email_address,
                  :billing_address, :receipt, :customer_signature,
                  :customer_communication, :uncategorized_file,
                  :uncategorized_text, :service_date, :service_documentation,
                  :shipping_address, :shipping_carrier, :shipping_date,
                  :shipping_documentation, :shipping_tracking_number
  end

  # Representation of a {Dispute} object in the Payment Service.
  class Dispute < StripeHash
    attr_accessor :id, :status, :reason, :amount_cents, :currency,
                  :merchant_id, :has_evidence, :past_due,
                  :submission_count

    attr_reader :evidence, :due_by, :created_at, :charge

    def evidence=(attrs)
      @evidence = Evidence.new(attrs)
    end

    def update(current_user, new_evidence, locale: 'en')
      Connector
        .new(locale: locale)
        .update_dispute(current_user, id, evidence: new_evidence)
    end

    def due_by=(val)
      @due_by = Time.parse(val).to_date
    end

    def created_at=(val)
      @created_at = Time.parse(val).to_date
    end

    def charge=(attrs)
      @charge = Charge.new(attrs)
    end

    def self.from_payment_service(dispute_id, locale: 'en')
      d = Connector.new(locale: locale).get_dispute(dispute_id)
      Dispute.new(d)
    end

    def self.collection_from_payment_service(params = {})
      connector = Connector.new(locale: params['locale'] || 'en')
      service_resp = connector.get_disputes(params)
      Collection.new(service_resp) do |response|
        response['disputes'].map { |h| new(h) }
      end
    end
  end
end
