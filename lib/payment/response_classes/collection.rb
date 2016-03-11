module ShorePayment
  # Class encapsulating a collection from the payment service
  # It contains the collection and also pagination information
  class Collection < StripeHash
    attr_accessor :current_page, :per_page, :total_pages,
                  :total_count, :collection

    def initialize(response, &block)
      @collection = block.yield(response)
      super(response['meta'])
    end
  end
end
