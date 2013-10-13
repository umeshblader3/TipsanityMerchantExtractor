module TipsanityMerchantExtractor
  # include LinkShare

  module Rakuten
    def self.extended(base)
      if base == AttributeExtractor
        base.send :include, Rakuten
      end
    end

    def is_merchant_linkshare_rakuten?(merchant_url)
      is_rakuten = ((URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]) or !(URI(merchant_url).host.match(/rakuten/).nil?))
      if is_rakuten
        block_given? ? true : ((URI(merchant_url).host == TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten]) ? TipsanityMerchantExtractor::RegisteredMerchantList::REGISTERED_MERCHANT[:linkshare][0][:rakuten] : URI(merchant_url).host)
      else
        false
      end
    end

    def extract_linkshare_rakuten(merchant_url, token, mid)
      if is_merchant_linkshare_rakuten?(merchant_url){}
        path_array = URI(merchant_url).path.split('/')
        skuid_stringed = path_array.last.gsub(/\D/, "")
        skuid = skuid_stringed.to_i==0 ? nil : skuid_stringed.to_i
        if skuid
          begin
            scraped_screen = Nokogiri::HTML(open(merchant_url))
            @product_name = scraped_screen.search('#AuthorArtistTitle_productTitle').first.text
            @description = scraped_screen.search('#divDescription').first.text
            @list_price = scraped_screen.search('#spanMainListPrice').first.text.gsub(/[$]/, "").to_f
            @final_price = scraped_screen.search('#spanMainTotalPrice').first.text.gsub(/[$]/, "").to_f
            @image_url = scraped_screen.search('#ImageVideo_ImageRepeater_ctl00_Image').first.attributes["src"].value
            buy_url = "http://getdeeplink.linksynergy.com/createcustomlink.shtml?token=#{token}&mid=#{mid}&murl=#{merchant_url}"
            @details_url = Nokogiri::HTML(open(buy_url)).search("p").text# it needs token to retrive buy url
            @categories = scraped_screen.search('#anchorSimilarProds').first.text
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

    def find_product_rakuten merchant_url, token, mid
      extract_linkshare_rakuten merchant_url, token, mid
    end
  end
end