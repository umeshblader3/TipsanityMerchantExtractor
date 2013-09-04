module TipsanityMerchantExtractor
	class RegisteredMerchantList
		REGISTERED_MERCHANT = {
			amazon: "www.amazon.com",
			cjunction: {
				bestbuy: 'www.bestbuy.com'
			},
			linkshare: [
				{
					rakuten: "www.rakuten.com",
					mid: 36342
				},
				{
					tigerdirect: "www.tigerdirect.com",
					mid: 14028
				}
			]
		}#%w{www.amazon.com www.commissionjunction.com www.link_share.com}
	end
end