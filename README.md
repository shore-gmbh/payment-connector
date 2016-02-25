# Payment::Connector
[![Build Status](https://travis-ci.org/shore-gmbh/payment-connector.svg?branch=master)](https://travis-ci.org/shore-gmbh/payment-connector)

Talks to the Shore Payment Service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'payment-connector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install payment-connector

## Usage

```ruby
ShorePayment.configure do |config|
  config.base_uri = 'payment_service_url'
  config.secret = 'secret'
end

ShorePayment::Connector.organizations
```


TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shore-gmbh/payment-connector.
