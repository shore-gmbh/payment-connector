# TSS::Connector

Talks to TSS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tss-connector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tss-connector

## Usage

```ruby
TSS.configure do |config|
  config.base_uri = 'tss_url'
  config.secret = 'secret'
end

TSS.load!
```


TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shore-gmbh/tss-connector.
