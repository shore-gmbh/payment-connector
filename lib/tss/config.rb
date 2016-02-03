module TSS #:nodoc:
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      require_relative 'connector'
    end
  end


  class Configuration #:nodoc:
    attr_accessor :base_uri, :secret

    def initialize
      @base_uri = 'http://localhost:5000/'
      @secret   = ''
    end
  end
end
