# coding: utf-8
require_relative 'lib/tss/version'

Gem::Specification.new do |spec|
  spec.name          = 'tss-connector'
  spec.version       = TSS::VERSION
  spec.authors       = ['Cristian Eigel']
  spec.email         = ['cristian.eigel@shore.com']

  spec.summary       = 'Connector for TSS'
  spec.description   = 'Easy access to TSS and its data.'
  spec.homepage      = 'http://shore.com'
  spec.license       = 'Nonstandard'

  spec.files = Dir['{lib,spec}/**/*.rb'] + ['README.md', 'Rakefile']
  spec.test_files = Dir['spec/**/*.rb']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.10.2'
  spec.add_dependency 'activesupport', '~> 3.2'
  spec.add_dependency 'tzinfo', '~> 0.3'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.35.1'
  spec.add_development_dependency 'overcommit', '~> 0.31'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
end
