module TSS
  class HttpRetriever #:nodoc:
    include HTTParty
    base_uri TSS.configuration.base_uri

    def self.auth_credentials
      @auth_credentials ||= {
        basic_auth: {
          username: TSS.configuration.secret.freeze,
          password: TSS.configuration.password.freeze
        }
      }.freeze
    end

    # Define variants of all HTTParty request methods with authentication
    # support.
    self::Request::SupportedHTTPMethods
      .map { |x| x.name.demodulize.downcase }.each do |method|
      define_singleton_method("authenticated_#{method}") do |path, options = {}|
        send(method, path, options.merge(auth_credentials))
      end
    end
  end
end
