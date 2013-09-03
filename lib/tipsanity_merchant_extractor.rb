require "tipsanity_merchant_extractor/version"
require 'uri'
require 'open-uri'
require 'nori'
require 'nokogiri'
# require 'hashie'

# require 'asin_configuration'
require 'commission_junction'

module TipsanityMerchantExtractor
  module UrlFormatter
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
    REGISTERED_MERCHANT = {amazon: "www.amazon.com", cjunction: {bestbuy: 'www.bestbuy.com'}, linkshare: [{rakuten: "www.rakuten.com", mid: 36342}, {tigerdirect: "www.tigerdirect.com", mid: 14028}]}#%w{www.amazon.com www.commissionjunction.com www.link_share.com}
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
                  :is_dp,
                  :categories,
                  :response_object,
                  :product_token,
                  :options

    class << self
      def who_is_merchant(merchant_url)
        case URI(merchant_url).host
        when is_merchant_amazon?(merchant_url)
          REGISTERED_MERCHANT[:amazon]
        when is_merchant_cj_bestbuy?(merchant_url)
          REGISTERED_MERCHANT[:cjunction][:bestbuy]
        when is_merchant_linkshare_rakuten?(merchant_url)
          REGISTERED_MERCHANT[:linkshare][0][:rakuten]
        else
          "this merchant is not registered merchant with our system. Please recommend us to affliate with us."
          # URI(merchant_url).host
        end
      end

      def is_merchant_amazon?(merchant_url)
        if URI(merchant_url).host == REGISTERED_MERCHANT[:amazon]
          block_given? ? true : REGISTERED_MERCHANT[:amazon]
        else
          false
        end
      end

      def is_merchant_cj_bestbuy?(merchant_url)
        if URI(merchant_url).host == REGISTERED_MERCHANT[:cjunction][:bestbuy]
          block_given? ? true : REGISTERED_MERCHANT[:cjunction][:bestbuy]
        else
          false
        end
      end

      def is_merchant_linkshare_rakuten?(merchant_url)
        is_rakuten = ((URI(merchant_url).host == REGISTERED_MERCHANT[:linkshare][0][:rakuten]) or !(URI(merchant_url).host.match(/rakuten/).nil?))
        if is_rakuten
          block_given? ? true : ((URI(merchant_url).host == REGISTERED_MERCHANT[:linkshare][0][:rakuten]) ? REGISTERED_MERCHANT[:linkshare][0][:rakuten] : URI(merchant_url).host)
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

      def extract_linkshare(merchant_url)
        capitalized_product_name = nil
        if is_merchant_linkshare_rakuten?(merchant_url){}
          path = URI(URI.unescape merchant_url).path
          element_array = path.split("/")
          product_name = element_array[element_array.index("p")+1] if element_array.include?("p")
          product_name = element_array[element_array.index("prod")+1] if element_array.include?("prod")
          capitalized_product_name = product_name.gsub(/\d/,'').split('-').delete_if{|x| x==""}.collect{|x| x.capitalize}[0..6].join(" ")
          return capitalized_product_name
        end
      end

      def merchant_amazon_path(merchant_url)
        if is_merchant_amazon?(merchant_url){}
          path = URI(merchant_url).path
        else
          "It is not amazon merchant"
        end
      end


    end
    # end of self methods

    def initialize merchant_url, *args
      @options = args.extract_options!
      @merchant_url = UrlFormatter.format_url merchant_url
      @host_provider = URI(@merchant_url).host

      case self.class.who_is_merchant(@merchant_url)
      when REGISTERED_MERCHANT[:amazon]
        client = ASIN::Client.instance
        product = client.lookup filtered_asin_from_amazon_path
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
          @final_price = product.first.raw.include?("OfferSummary") ? product.first.raw.OfferSummary.LowestNewPrice ? product.first.raw.OfferSummary.LowestNewPrice.Amount.to_f/100 : "0.00".to_f : "0.00".to_f
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

      when REGISTERED_MERCHANT[:cjunction][:bestbuy]
        call_to_cj(@options[:cj][:developer_key], @options[:cj][:website_id]) do |product|
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
            @product_name = nil
            @description = nil
            @list_price = nil
            @currency_code = nil
            @image_url = nil
            @details_url = nil
            @categories = nil
            @response_object = nil
          end
        end

      when REGISTERED_MERCHANT[:linkshare][0][:rakuten]
        call_to_linkshare(@options[:linkshare][:token], REGISTERED_MERCHANT[:linkshare][0][:mid]) do |product|
          if product
            serialized_product_detail = product.first.serialize
            product_details_hash = Nori.new(strip_namespaces: true, parser: :nokogiri, convert_tags_to: lambda{|tag| tag.snakecase.to_sym}).parse serialized_product_detail
            product_hashie = Hashie::Mash.new product_details_hash
            if product_hashie.result.item
              @product_name = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.productname : product_hashie.result.item.productname
              @description = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.description.try(:long) : product_hashie.result.item.description.try(:long)
              @list_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.listprice : product_hashie.result.item.listprice
              @final_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.saleprice : product_hashie.result.item.saleprice
              # @currency_code = product.currency
              @image_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.imageurl : product_hashie.result.item.imageurl
              @details_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.linkurl : product_hashie.result.item.linkurl
              @categories = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.category.try(:primary) : product_hashie.result.item.category.try(:primary)
              @response_object = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first : product_hashie.result.item
              @product_token = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.sku : product_hashie.result.item.sku
            else
              @product_name = @description = @list_price = @final_price = @currency_code = @image_url = @details_url = @categories = @response_object = @product_token = nil
            end
          else
            @product_name = nil
            @description = nil
            @list_price = nil
            @currency_code = nil
            @image_url = nil
            @details_url = nil
            @categories = nil
            @response_object = nil
          end
        end

      else
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



    def call_to_cj(developer_key, website_id)

      cj = CommissionJunction.new(developer_key, website_id)
      case self.class.who_is_merchant(@merchant_url)
      when REGISTERED_MERCHANT[:cjunction][:bestbuy]
        product_name = self.class.extract_cj_bestbuy(@merchant_url){|product_name| product_name}
        skuId = self.class.extract_cj_bestbuy(@merchant_url){|product_name, query| CGI.parse(query)["skuId"].first}
        yield cj.product_search("keywords" => product_name, "advertiser-ids" => "notjoined", "advertiser-sku" => skuId).collect{|product| product}.first
      else
      end
    end

    def call_to_linkshare(token, mid)
      product_name = self.class.extract_linkshare(@merchant_url)
      linkshare_base_url = "http://productsearch.linksynergy.com/productsearch?"
      query_hash = {token: token, keyword: product_name, mid: mid, exact: product_name.split(" ").pop(2).join(" ")}
      query = URI.encode_www_form query_hash
      request_url = [linkshare_base_url, query].join
      response_xml = Nokogiri::XML open(URI.escape(request_url))
      unless response_xml.xpath("//Errors").empty?
        product = nil
      else
        product = response_xml.xpath("//result")
      end
      yield product
    end

    def filtered_asin_from_amazon_path
      split_path = self.class.merchant_amazon_path(@merchant_url).split('/')
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

class Array
  def extract_options!
    if last.is_a?(::Hash)# && last.extractable_options?
      pop
    else
      {}
    end
  end
  def extractable_options?
    instance_of?(Hash)
  end
end