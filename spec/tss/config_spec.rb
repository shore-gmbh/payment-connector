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

  describe '.load!' do
    it 'loads the Connector class' do
      expect { TSS::Connector.new }.to raise_error(ArgumentError)
      TSS.load!
      expect { TSS::Connector.new('a') }.not_to raise_error
    end
  end
end
