require 'spec_helper'

describe 'ShorePayment Library Configuration' do
  before do
    ShorePayment.configure do |config|
      config.base_uri = 'foo'
      config.secret = 'bar'
    end
  end

  it 'stores base_uri' do
    expect(ShorePayment.configuration.base_uri).to eq('foo')
  end

  it 'stores secret' do
    expect(ShorePayment.configuration.secret).to eq('bar')
  end

  it 'has ShorePayment::Connnector defined' do
    expect(ShorePayment.const_defined?(:Connector)).to be_truthy
  end
end
