require_relative 'tss/config'

module TSS #:nodoc:
  # Authentication credentials are stored in constants, make sure
  # configuration is set before requiring the connector.
  def self.load!
    if TSS.configuration.base_uri.empty?
      puts 'Missing TSS base_uri config'
      exit
    end

    require_relative 'tss/connector'
  end
end
