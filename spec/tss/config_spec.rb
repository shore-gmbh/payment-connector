require 'spec_helper'

describe 'TSS Library Configuration' do
  before do
    TSS.configure do |config|
      config.base_uri = 'foo'
      config.secret = 'bar'
    end
  end

  it 'stores base_uri' do
    expect(TSS.configuration.base_uri).to eq('foo')
  end

  it 'stores secret' do
    expect(TSS.configuration.secret).to eq('bar')
  end

  it 'has TSS::Connnector defined' do
    expect(TSS.const_defined?(:Connector)).to be_truthy
  end
end
