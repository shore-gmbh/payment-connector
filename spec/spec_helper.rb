$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tss-connector'
require 'pry'
require 'securerandom'

Time.zone = 'Europe/Berlin'

TSS.configure do |config|
  config.base_uri = 'testhost'
  config.secret = 'secret'
end
