$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'payment-connector'
require 'pry'
require 'securerandom'
require 'support/stripe_payment'

Time.zone = 'Europe/Berlin'

ShorePayment.configure do |config|
  config.base_uri = 'testhost'
  config.secret = 'secret'
end

def mock_created(body = '{}')
  double('Resource Created', code: 201, body: body)
end

def mock_success(body = '{}')
  double('Successful Response', code: 200, body: body)
end

def mock_server_error
  double('Internal Server Error', code: 500)
end

def mock_unprocessable_entity_error(body = '{}')
  double('Unprocessable Entity error', code: 422, body: body)
end

def mock_not_found
  double('Not Found', code: 404)
end

def auth_mock
  hash_including(basic_auth: an_instance_of(Hash))
end
