module ShorePayment
  class HttpRetriever #:nodoc:
    include HTTParty
    base_uri ShorePayment.configuration.base_uri

    def auth_credentials
      @auth_credentials ||= {
        basic_auth: {
          username: ShorePayment.configuration.secret.freeze,
          password: ShorePayment.configuration.password.freeze
        }
      }.freeze
    end

    # Define variants of all HTTParty request methods with authentication
    # support.
    self::Request::SupportedHTTPMethods
      .map { |x| x.name.demodulize.downcase }.each do |method|
      define_method("authenticated_#{method}") do |path, options = {}|
        self.class.send(method, path, options.merge(auth_credentials))
      end
    end
  end
end
