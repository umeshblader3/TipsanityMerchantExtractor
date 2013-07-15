require "tipsanity_merchant_extractor/version"
require 'uri'

# require 'asin_configuration'

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
                  :is_dp

    def initialize merchant_url
      @merchant_url = UrlFormatter.format_url merchant_url
      @host_provider = URI(@merchant_url).host

      case who_is_merchant
      when REGISTERED_MERCHANT[:amazon]
        client = ASIN::Client.instance
        product = client.lookup filtered_asin_from_amazon_path
        @product_name = product.first.title
        # filtered_asin_from_amazon_path{|is_dp| is_dp == false} ? @description = product.first.review : 
        @description = product.first.raw.EditorialReviews.EditorialReview.first.Content 
        @list_price = product.first.amount.to_f/100 || product.first.raw.ItemAttributes.ListPrice.Amount.to_f/100
        @currency_code = product.first.raw.ItemAttributes.ListPrice.CurrencyCode
        @expiry_date = Date.today
        @image_url = product.first.image_url || product.first.raw.ImageSets.ImageSet.LargeImage.URL
        @details_url = product.first.details_url

      end
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

    def filtered_asin_from_amazon_path
      split_path = merchant_amazon_path.split('/')
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
  end

end
