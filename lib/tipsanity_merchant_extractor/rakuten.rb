module TipsanityMerchantExtractor
	module Rakuten
		def is_merchant_linkshare_rakuten?(merchant_url)
      is_rakuten = ((URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]) or !(URI(merchant_url).host.match(/rakuten/).nil?))
      if is_rakuten
        block_given? ? true : ((URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]) ? TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten] : URI(merchant_url).host)
      else
        false
      end
    end

    def extract_linkshare_rakuten(merchant_url)
      if is_merchant_inkshare_rakuten?(merchant_url){}
        path = URI(merchant_url).path
        product_name = path.split("/")[path.split("/").index("site")+1] if path.split("/").include?("site")
        query = URI(merchant_url).query
        yield(product_name, query)
      else
        block_given? ? yield("It is not bestbuy merchant connected with commission junction.") : "It is not bestbuy merchant connected with commission junction."
      end
    end

    def find_product_rakuten merchant_url, cj
      product_name = extract_linkshare_rakuten(merchant_url){|product_name| product_name}
      skuId = extract_linkshare_rakuten(merchant_url){|product_name, query| CGI.parse(query)["skuId"].first}
      cj.product_search("keywords" => product_name, "advertiser-ids" => "notjoined", "advertiser-sku" => skuId).collect{|product| product}.first
    end
	end
end