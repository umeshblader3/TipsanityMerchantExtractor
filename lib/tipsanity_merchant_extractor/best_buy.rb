module TipsanityMerchantExtractor
  module BestBuy
    def is_merchant_cj_bestbuy?(merchant_url)
      if URI(merchant_url).host == RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
        block_given? ? true : RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:bestbuy]
      else
        false
      end
    end

    def extract_cj_bestbuy(merchant_url)
      if is_merchant_cj_bestbuy?(merchant_url){}
        path = URI(merchant_url).path
        product_name = path.split("/")[path.split("/").index("site")+1] if path.split("/").include?("site")
        query = URI(merchant_url).query
        yield(product_name, query)
      else
        block_given? ? yield("It is not bestbuy merchant connected with commission junction.") : "It is not bestbuy merchant connected with commission junction."
      end
    end

    def find_product_best_buy merchant_url, cj, options = {}
      product_name = extract_cj_bestbuy(merchant_url){|product_name| product_name}
      skuId = extract_cj_bestbuy(merchant_url){|product_name, query| CGI.parse(query)["skuId"].first}
      cj.product_search("keywords" => product_name, "advertiser-ids" => options["advertiser-ids"], "advertiser-sku" => skuId).collect{|product| product}.first
    end
  end
end