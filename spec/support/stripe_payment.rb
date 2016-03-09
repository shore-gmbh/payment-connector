# rubocop:disable MethodLength
def payment_service_organization_response(oid, attributes)
  {
    'id' => oid,
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
          'first_name' => 'Joe',
          'last_name' => 'Smith',
          'dob' => {
            'year' => '1980',
            'month' => '11',
            'day' => '01'
          }
        }, {
          'first_name' => 'Jane',
          'last_name' => 'Smith',
          'dob' => {
            'year' => '1981',
            'month' => '12',
            'day' => '21'
          }
        }]
      }
    },
    'meta' => {}
  }.merge(attributes)
end
