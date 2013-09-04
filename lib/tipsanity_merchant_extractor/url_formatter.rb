require 'uri'
module TipsanityMerchantExtractor
  module UrlFormatter
    def format_url
      URI.unescape @url
      if @url.to_s !~ url_regexp && "http://#{@url}" =~ url_regexp
        "http://#{@url.gsub(/\A[[:punct:]]*/,'')}"
      else
        @url
      end
    end

    def url_regexp
      /http:|https:/ #[http:|https:] means that any of the charactor inside [] is matching.
    end

    def valid_url
      if @url =~ url_regexp
        true
      else
        false
      end
    end
  end
end