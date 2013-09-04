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
	end
end