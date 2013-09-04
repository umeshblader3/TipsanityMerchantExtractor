require "tipsanity_merchant_extractor/version"
require 'open-uri'
require 'nori'
require 'nokogiri'

module TipsanityMerchantExtractor
  autoload :UrlFormatter,           'tipsanity_merchant_extractor/url_formatter'
  autoload :AttributeExtractor,     'tipsanity_merchant_extractor/attribute_extractor'
  autoload :Amazon,                 'tipsanity_merchant_extractor/amazon'
  autoload :RegisteredMerchantList, 'tipsanity_merchant_extractor/registered_merchant_list'
  autoload :LinkShare,              'tipsanity_merchant_extractor/linkshare'
  autoload :Cj,                     'tipsanity_merchant_extractor/cj'
  autoload :Rakuten,                'tipsanity_merchant_extractor/rakuten'
  autoload :BestBuy,                'tipsanity_merchant_extractor/best_buy'

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