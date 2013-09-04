module TipsanityMerchantExtractor
	class AttributeExtractor
    include UrlFormatter
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
      @merchant_url = format_url
      @host_provider = URI(@merchant_url).host

      case self.class.who_is_merchant(@merchant_url)
      when RegisteredMerchantList::REGISTERED_MERCHANT[:amazon]
      	find_product_amazon @merchant_url

      when RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
      	find_product_cj @merchant_url

      when RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]
        self.class.call_to_linkshare(@merchant_url, @options[:linkshare][:token], RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:mid]) do |product|
          if product
            serialized_product_detail = product.first.serialize
            product_details_hash = Nori.new(strip_namespaces: true, parser: :nokogiri, convert_tags_to: lambda{|tag| tag.snakecase.to_sym}).parse serialized_product_detail
            product_hashie = Hashie::Mash.new product_details_hash
            if product_hashie.result.item
              @product_name = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.productname : product_hashie.result.item.productname
              @description = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.description.long : product_hashie.result.item.description.long
              @list_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.listprice : product_hashie.result.item.listprice
              @final_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.saleprice : product_hashie.result.item.saleprice
              # @currency_code = product.currency
              @image_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.imageurl : product_hashie.result.item.imageurl
              @details_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.linkurl : product_hashie.result.item.linkurl
              @categories = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.category.primary : product_hashie.result.item.category.primary
              @response_object = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first : product_hashie.result.item
              @product_token = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.sku : product_hashie.result.item.sku
            else
              @product_name = @description = @list_price = @final_price = @currency_code = @image_url = @details_url = @categories = @response_object = @product_token = nil
            end
          else
            @product_name = nil
            @description = nil
            @list_price = nil
            @currency_code = nil
            @image_url = nil
            @details_url = nil
            @categories = nil
            @response_object = nil
          end
        end

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
      end
    end
  end
end