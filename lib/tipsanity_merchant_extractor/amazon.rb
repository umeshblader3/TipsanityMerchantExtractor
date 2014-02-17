# require 'asin_configuration'

module TipsanityMerchantExtractor
	module Amazon
    def self.extended(base)
    	if base == AttributeExtractor
    		base.send :include, FindAmazon
    	end
    end

		def is_merchant_amazon?(merchant_url)
      if URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:amazon]
        block_given? ? true : TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:amazon]
      else
        false
      end
    end

    def merchant_amazon_path(merchant_url)
      if self.is_merchant_amazon?(merchant_url){}
        path = URI(merchant_url).path
      else
        "It is not amazon merchant"
      end
    end

    def filtered_asin_from_amazon_path(merchant_url)
      split_path = self.merchant_amazon_path(merchant_url).split('/')
      if split_path.include? 'gp'
        if block_given?
          @is_dp = false
          yield @is_dp
        else
          asin = split_path[split_path.index('gp')+2]
        end
      elsif split_path.include? 'dp'
        if block_given?
          @is_dp = true
          yield @is_dp
        else
          asin = split_path[split_path.index('dp')+1]
        end
      else
        "path does not have asin"
      end
    end

    module FindAmazon
    	include Amazon
    	def find_product_amazon(merchannt_url)
	    	client = ASIN::Client.instance
        product = client.lookup filtered_asin_from_amazon_path(merchant_url)
        unless product.empty?

          @response_object = product
          @product_name = product.first.title
          # filtered_asin_from_amazon_path{|is_dp| is_dp == false} ? @description = product.first.raw.EditorialReviews.EditorialReview.Content : @description = product.first.raw.EditorialReviews.EditorialReview.first.Content 
          @description = product.first.raw.keys.include?("EditorialReviews") ? (product.first.raw.EditorialReviews.EditorialReview.kind_of?(Array) ? product.first.raw.EditorialReviews.EditorialReview.first.Content : product.first.raw.EditorialReviews.EditorialReview.Content) : nil
          @list_price = product.first.amount.to_f/100 || product.first.raw.ItemAttributes.ListPrice.Amount.to_f/100
          @currency_code = product.first.raw.ItemAttributes.ListPrice.CurrencyCode
          @expiry_date = Date.today
          @image_url = product.first.image_url || product.first.raw.ImageSets.ImageSet.LargeImage.URL
          @details_url = product.first.details_url
          @final_price = product.first.raw.include?("OfferSummary") ? ((product.first.raw.OfferSummary.LowestNewPrice and product.first.raw.OfferSummary.LowestNewPrice.Amount) ? product.first.raw.OfferSummary.LowestNewPrice.Amount.to_f/100 : nil) : nil
          @categories = product.first.raw.ItemAttributes.Binding
          @product_token = product.first.asin
        else
          @response_object = nil
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
end