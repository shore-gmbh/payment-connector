# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tss/version'

Gem::Specification.new do |spec|
  spec.name          = 'tss-connector'
  spec.version       = TSS::VERSION
  spec.authors       = ['Cristian Eigel']
  spec.email         = ['cristian.eigel@shore.com']

  spec.summary       = 'Connector for TSS'
  spec.description   = 'Easy access to TSS and its data.'
  spec.homepage      = 'http://shore.com'
  spec.license       = 'Nonstandard'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.10.2'
  spec.add_dependency 'activesupport', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.35.1'
  spec.add_development_dependency 'overcommit', '~> 0.29.1'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
end
