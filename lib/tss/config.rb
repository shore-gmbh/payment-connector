module TSS #:nodoc:
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration #:nodoc:
    attr_accessor :base_uri, :secret

    def initialize
      @base_uri = 'http://localhost:5000/'
      @secret   = ''
    end
  end
end
