module TipsanityMerchantExtractor
	module OneEightThousandLighting
		def is_merchant_cj_one_eight_thousand_lighting?(merchant_url)
      if URI(merchant_url).host == RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:one_eight_thousand_lighting]
        block_given? ? true : RegisteredMerchantList::REGISTERED_MERCHANT[:cjunction][:one_eight_thousand_lighting]
      else
        false
      end
    end

    def extract_cj_one_eight_thousand_lighting(merchant_url)
      if is_merchant_cj_one_eight_thousand_lighting?(merchant_url){}
        path = URI(merchant_url).path
        product_name = path.split("/")[path.split("/").index("site")+1] if path.split("/").include?("site")
        query = URI(merchant_url).query
        yield(product_name, query)
      else
        block_given? ? yield("It is not bestbuy merchant connected with commission junction.") : "It is not bestbuy merchant connected with commission junction."
      end
    end

    def find_product_one_eight_thousand_lighting merchant_url, cj
    	product_name = extract_cj_one_eight_thousand_lighting(merchant_url){|product_name| product_name}
      skuId = extract_cj_one_eight_thousand_lighting(merchant_url){|product_name, query| CGI.parse(query)["skuId"].first}
      cj.product_search("keywords" => product_name, "advertiser-ids" => "notjoined", "advertiser-sku" => skuId).collect{|product| product}.first
    end
	end
end