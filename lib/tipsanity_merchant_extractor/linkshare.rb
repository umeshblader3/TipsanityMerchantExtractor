module TipsanityMerchantExtractor
  module LinkShare
	include Rakuten
    def self.extended(base)
      if base == AttributeExtractor
        base.send :include, FindLinkShare
      end
    end
		def call_to_linkshare(merchant_url, token, mid)
      product_name = extract_linkshare(merchant_url)
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
    module FindLinkShare
      include LinkShare
      def find_product_linkshare merchant_url
        call_to_linkshare(@merchant_url, @options[:linkshare][:token], RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:mid]) do |product|
          if product
            serialized_product_detail = product.first.serialize
            product_details_hash = Nori.new(strip_namespaces: true, parser: :nokogiri, convert_tags_to: lambda{|tag| tag.snakecase.to_sym}).parse serialized_product_detail
            product_hashie = Hashie::Mash.new product_details_hash
            if product_hashie.result.item
              @product_name = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.productname : product_hashie.result.item.productname
              @description = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.description.long : product_hashie.result.item.description.long
              @list_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.listprice : product_hashie.result.item.listprice
              @final_price = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.saleprice : product_hashie.result.item.saleprice
              # @currency_code = product.currency
              @image_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.imageurl : product_hashie.result.item.imageurl
              @details_url = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.linkurl : product_hashie.result.item.linkurl
              @categories = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.category.primary : product_hashie.result.item.category.primary
              @response_object = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first : product_hashie.result.item
              @product_token = product_hashie.result.item.is_a?(Array) ? product_hashie.result.item.first.sku : product_hashie.result.item.sku
            else
              @product_name = @description = @list_price = @final_price = @currency_code = @image_url = @details_url = @categories = @response_object = @product_token = nil
            end
          else
            @product_name = @description = @list_price = @currency_code = @image_url = @details_url = @categories = @response_object = nil
          end
        end
      end
    end
	end
end