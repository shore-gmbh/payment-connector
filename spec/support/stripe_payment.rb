# rubocop:disable MethodLength
def payment_service_merchant_response(mid, attributes)
  {
    'id' => mid,
    'supported_transaction_types' => ['cash'],
    'cash' => {},
    'stripe_publishable_key' => 'test key',
    'stripe' => {
      'account_id' => 'acct_test',
      'verification_disabled_reason' => 'fields_needed',
      'verification_due_by' => '2016-04-03',
      'verification_fields_needed' => [
        'external_account',
        'legal_entity.dob.day',
        'legal_entity.dob.month',
        'legal_entity.dob.year',
        'legal_entity.first_name',
        'legal_entity.last_name',
        'legal_entity.type',
        'tos_acceptance.date',
        'tos_acceptance.ip'
      ],
      'active_bank_accounts' => [{
        'status' => 'new',
        'currency' => 'usd',
        'bank_name' => 'STRIPE TEST BANK',
        'name' => nil,
        'last4' => '6789'
      }, {
        'status' => 'new',
        'currency' => 'eur',
        'bank_name' => 'STRIPE TEST BANK',
        'name' => 'Body and Soul',
        'created_at' => '2016-02-05',
        'last4' => '3000'
      }],
      'legal_entity' => {
        'address' => {
          'city' => 'Munchen',
          'country' => 'DE',
          'line1' => 'Mittenwalder Str. 1',
          'line2' => '',
          'postal_code' => '82000',
          'state' => ''
        },
        'first_name' => 'First',
        'last_name' => 'Last',
        'dob' => {
          'year' => '1970',
          'month' => '2',
          'day' => '3'
        },
        'type' => 'company',
        'additional_owners' => [{
          'address' => {
            'city' => 'Munchen',
            'country' => 'DE',
            'line1' => 'Mittenwalder Str. 1',
            'line2' => '',
            'postal_code' => '82000',
            'state' => ''
          },
          'first_name' => 'Joe',
          'last_name' => 'Smith',
          'dob' => {
            'year' => '1980',
            'month' => '11',
            'day' => '01'
          },
          'verification' => {
            'details' => 'additional detail',
            'details_code' => 'scan_corrupt',
            'document' => 'fil_95BZxW2eZvKYlo2CvQbrn9dc',
            'status' => 'verified'
          }
        }, {
          'first_name' => 'Jane',
          'last_name' => 'Smith',
          'dob' => {
            'year' => '1981',
            'month' => '12',
            'day' => '21'
          }
        }],
        'verification' => {
          'details' => 'detail',
          'details_code' => 'scan_corrupt',
          'document' => 'fil_15BZxW2eZvKYlo2CvQbrn9dc',
          'status' => 'verified'
        }
      }
    }
  }.merge(attributes)
end

def payment_service_disputes_response(attributes = {})
  {
    'meta' => {
      'current_page' => 1,
      'per_page' => 20,
      'total_pages' => 1,
      'total_count' => 0
    },
    'disputes' => [
      {
        'created_at' => '2016-02-18T10:10:10Z',
        'dispute_id' => 'dp_17Vv962eZvKYlo2CU7XhGGzB',
        'due_by' => '2016-03-18T10:10:10Z',
        'has_evidence' => false,
        'merchant_id' => SecureRandom.uuid,
        'reason' => 'general',
        'status' => 'lost'
      },
      {
        'created_at' => '2016-02-19T11:09:10Z',
        'dispute_id' => 'dp_18Vv962eZvKYlo2CU7XhGGzB',
        'due_by' => '2016-03-19T11:09:10Z',
        'has_evidence' => true,
        'merchant_id' => SecureRandom.uuid,
        'reason' => 'bank_cannot_process',
        'status' => 'under_review'
      }
    ]
  }.merge(attributes).to_json
end

def payment_service_dispute_response(mid, attributes)
  {
    'dispute' =>
    {
      'id' => 'dp_17Vv962eZvKYlo2CU7XhGGzB',
      'status' => 'under_review',
      'reason' => 'bank_cannot_process',
      'amount_cents' => 10_000,
      'currency' => 'eur',
      'created_at' => '2016-02-19T11:09:10Z',
      'merchant_id' => mid,
      'due_by' => '2016-03-19T11:09:10Z',
      'has_evidence' => true,
      'past_due' => false,
      'submission_count' => 0,
      'charge' => {
        'charge_id' => 'ch_17kyvuBJMmId6xqIDWIRAimq'
      },
      'evidence' =>
      {
        'product_description' => nil,
        'customer_name' => nil,
        'customer_email_address' => nil,
        'billing_address' => nil,
        'receipt' => nil,
        'customer_signature' => nil,
        'customer_communication' => nil,
        'uncategorized_file' => nil,
        'uncategorized_text' => nil,
        'service_date' => nil,
        'service_documentation' => nil,
        'shipping_address' => nil,
        'shipping_carrier' => nil,
        'shipping_date' => nil,
        'shipping_documentation' => nil,
        'shipping_tracking_number' => nil
      }
    }
  }.merge(attributes)
end

def payment_service_charge_response(attributes = {})
  {
    'charge' =>
    {
      'charge_id' => 'ch_17ft3sBJMmId6xqIBzqPSK6a',
      'amount_cents' => 11_825,
      'amount_refunded_cents' => 1800,
      'status' => 'succeeded',
      'captured' => 'true',
      'customer_name' => 'James Bond',
      'customer_address' =>
      {
        'street' => 'Rosenheimerstr. 1145e',
        'zip' => '81321',
        'city' => 'Munchen'
      },
      'customer_email' => 'jb@mail.com',
      'credit_card_brand' => 'Visa',
      'credit_card_last4' => '1121',
      'description' => 'Lorem ipsum...',
      'currency' => 'eur',
      'created_at' => '2016-02-18T14:47:20Z',
      'services' =>
      [
        {
          'service_name' => 'Haircut Women',
          'service_price_cents' => 1800
        },
        {
          'service_name' => 'Haircut Women - Wash, cut and blow dry',
          'service_price_cents' => 1800
        }
      ]
    }
  }.merge(attributes)
end
