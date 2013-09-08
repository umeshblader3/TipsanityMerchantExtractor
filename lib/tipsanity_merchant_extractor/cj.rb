require 'commission_junction'

module TipsanityMerchantExtractor
  module Cj
    include BestBuy
    include OneEightThousandLighting
    def self.extended(base)
      if base == AttributeExtractor
        base.send :include, FindCj
      end
    end

    def call_to_cj(merchant_url, developer_key, website_id)

      cj = CommissionJunction.new(developer_key, website_id)
      case AttributeExtractor.who_is_merchant merchant_url
      when RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
        yield find_product_best_buy(merchant_url, cj, {"advertiser-ids" => "notjoined"})

      when RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:one_eight_thousand_lighting]
        yield find_product_one_eight_thousand_lighting(merchant_url, cj, {"advertiser-ids" => "notjoined"})

      end
    end

    module FindCj
      include Cj
      def find_product_cj merchant_url
        call_to_cj(merchant_url, @options[:cj][:developer_key], @options[:cj][:website_id]) do |product|
          if product

            @product_name = product.name
            @description = product.description
            @list_price = product.price
            @currency_code = product.currency
            @image_url = product.image_url
            @details_url = product.buy_url
            @categories = product.advertiser_category
            @response_object = product
            @product_token = self.class.extract_cj_bestbuy(@merchant_url){|product_name, query| CGI.parse(query)["skuId"].first}
          else
            @product_name = @description = @list_price = @currency_code = @image_url = @details_url = @categories = @response_object = nil
          end
        end
      end
    end
  end
end