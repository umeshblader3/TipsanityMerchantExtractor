module TipsanityMerchantExtractor
	module TigerDirect
		include LinkShare

		def self.extended(base)
      if base == AttributeExtractor
        base.send :include, TigerDirect
      end
    end

		def is_merchant_linkshare_tiger_direct?(merchant_url)
			URI(merchant_url).host
			if URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][1][:tiger_direct]
        block_given? ? true : TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][1][:tiger_direct]
      else
        false
      end
		end

		def find_product_tiger_direct merchant_url, token, mid
			if is_merchant_linkshare_tiger_direct?(merchant_url){}
				skuid_filter = URI.decode_www_form(URI(merchant_url).query).assoc("EdpNo")
				skuid = skuid_filter ? skuid_filter.last : nil
        if skuid
          begin
            scraped_screen = Nokogiri::HTML(open(merchant_url))
            @product_name = scraped_screen.search("#ProductReview .rightCol .prodName h1").text
            @description = scraped_screen.search("#WriteUp").text.strip
            list_price = scraped_screen.search("#ProductReview .rightCol .prodInfo dd.priceList").first || scraped_screen.search("#ProductReview .rightCol .prodInfo dd.pricemapa").first
            @list_price = list_price.text.gsub(/[$]/, "")#.to_f
            final_price = scraped_screen.search("#ProductReview .rightCol .prodInfo .salePrice").first || list_price
            @final_price = final_price.text.gsub(/[$]/,"")#.to_f 
            @image_url = scraped_screen.search("#ProductReview .leftCol .previewImgHolder a img").first.attributes["src"].value
            @details_url = provide_buy_url(token, mid, merchant_url)
            @categories = scraped_screen.search("#ProductReview .rightCol .breadCrumbs li a").first.text
            @response_object = scraped_screen
            @product_token = skuid
            @errors = []
          rescue
            @errors << "Some errors from api information"
          end
        else
          @errors << "Not valid Uri. Please make sure, Uri contain 'prod' and skuid."
        end
      else
        block_given? ? yield("It is not bestbuy merchant connected with commission junction.") : "It is not bestbuy merchant connected with commission junction."
      end
		end

	end
end