# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'payment/version'

Gem::Specification.new do |spec|
  spec.name          = 'payment-connector'
  spec.version       = ShorePayment::VERSION
  spec.authors       = ['Cristian Eigel']
  spec.email         = ['cristian.eigel@shore.com']

  spec.summary       = 'Connector for the Shore Payment Service'
  spec.description   = 'Easy access to the Payment Service and its data.'
  spec.homepage      = 'http://shore.com'
  spec.license       = 'Nonstandard'

  spec.files = Dir['{lib,spec}/**/*.rb'] + ['README.md', 'Rakefile']
  spec.test_files = Dir['spec/**/*.rb']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty'
  spec.add_dependency 'activesupport', '>= 3.2'
  spec.add_dependency 'tzinfo'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.37.2'
  spec.add_development_dependency 'overcommit', '~> 0.31'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
end
