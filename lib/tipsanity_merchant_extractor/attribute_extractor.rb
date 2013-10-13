module TipsanityMerchantExtractor
	class AttributeExtractor
    extend UrlFormatter
    [Amazon, LinkShare, Rakuten, BestBuy, Cj].each do |merchant|
    	extend merchant
    end
    
    attr_accessor :merchant_url,
                  :host_provider,
                  :product_name,
                  :description,
                  :final_price,
                  :list_price,
                  :expiry_date,
                  :currency_code,
                  :image_url,
                  :details_url,
                  :is_dp,
                  :categories,
                  :response_object,
                  :product_token,
                  :options
                  :errors

    class << self
      def who_is_merchant(merchant_url)
        case URI(merchant_url).host
        when is_merchant_amazon?(merchant_url)
          RegisteredMerchantList::REGISTERED_MERCHANT[:amazon]
        when is_merchant_cj_bestbuy?(merchant_url)
          RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
        when is_merchant_linkshare_rakuten?(merchant_url)
          RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]
        else
          "this merchant is not registered merchant with our system. Please recommend us to affliate with us."
          # URI(merchant_url).host
        end
      end
    end
    # end of self methods

    def initialize merchant_url, *args
      @options = args.extract_options!
      @url = merchant_url
      @merchant_url = self.class.format_url @url
      @host_provider = URI(@merchant_url).host
      @errors = []
      case self.class.who_is_merchant(@merchant_url)
      when RegisteredMerchantList::REGISTERED_MERCHANT[:amazon]
      	find_product_amazon @merchant_url

      when RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
      	find_product_cj @merchant_url

      when RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]
        find_product_rakuten @merchant_url, @options[:linkshare][:token], RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:mid]

      else
        @product_name = nil
        @description = nil
        @list_price = nil
        @currency_code = nil
        @expiry_date = nil
        @image_url = nil
        @details_url = nil
        @final_price = nil
        @categories = nil
        @errors << "Unable to retrive from api"
      end
    end
  end
end