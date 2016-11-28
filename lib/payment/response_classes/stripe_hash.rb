module ShorePayment
  # BaseClass for classes representing objects received from the
  # Payment Service response
  class StripeHash
    def initialize(attrs = {})
      update_attributes(attrs)
    end

    # Update object with this method. We have to take care updating 'nested'
    #   objects
    def update_attributes(attrs = {})
      attrs.each_pair do |attr, value|
        send(:"#{attr}=", value) if respond_to?(:"#{attr}=")
      end
    end
  end
end
