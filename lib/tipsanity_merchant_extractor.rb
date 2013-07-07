require "tipsanity_merchant_extractor/version"
require 'uri'
require File.join(File.dirname(File.expand_path(__FILE__)), 'asin_configuration')

module TipsanityMerchantExtractor
	module UrlFormatter
		REGISTERED_MERCHANT = {amazon: "www.amazon.com", cjunction: "www.commissionjunction.com", link_share: "www.link_share.com"}#%w{www.amazon.com www.commissionjunction.com www.link_share.com}
		class << self
			def format_url url
				URI.unescape url
				if url.to_s !~ url_regexp && "http://#{url}" =~ url_regexp
					"http://#{url.gsub(/\A[[:punct:]]*/,'')}"
				else
					url
				end
			end

			def url_regexp
				/http:|https:/ #[http:|https:] means that any of the charactor inside [] is matching.
			end

			def valid_url url
				if url =~ url_regexp
					true
				else
					false
				end
			end
		end
	end

	class AttributeExtractor
		include UrlFormatter
		attr_accessor :merchant_url, :host_provider, :product_name

		def initialize merchant_url
			@merchant_url = UrlFormatter.format_url merchant_url
			@host_provider = URI(@merchant_url).host
		end
		
		def who_is_merchant
			case @host_provider
			when is_merchant_amazon?
				REGISTERED_MERCHANT[:amazon]
			when "www.commissionjunction.com"
				"commissionjunction"
			else
				"this merchant is not registered with system"
			end
		end

		def is_merchant_amazon?
			if @host_provider == REGISTERED_MERCHANT[:amazon]
				block_given? ? true : @host_provider 
			else
				false
			end
		end

		def merchant_amazon_path
			if is_merchant_amazon?{}
				path = URI(@merchant_url).path
			else
				"It is not amazon merchant"
			end
		end

		def product_name
			case who_is_merchant
			when REGISTERED_MERCHANT[:amazon]
				client = ASIN::Client.instance
				product = client.lookup filtered_asin_from_amazon_path
				product.first.title
			end
		end

		def filtered_asin_from_amazon_path
			split_path = merchant_amazon_path.split('/')
			if split_path.include? 'gp'
				asin = split_path[split_path.index('gp')+2]
			elsif split_path.include? 'dp'
				asin = split_path[split_path.index('dp')+1]
			else
				"path does not have asin"
			end
		end
	end

end
