module TipsanityMerchantExtractor
	extend Rakuten
	module LinkShare
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

	end
end