require "spec_helper"

describe TipsanityMerchantExtractor::UrlFormatter do
	describe "url package" do
		it "add http:// if it is not privided" do
			TipsanityMerchantExtractor::UrlFormatter.format_url("example.com").should eq("http://example.com")
		end

		it "display the message valid url" do
			TipsanityMerchantExtractor::UrlFormatter.valid_url("https://example.com").should be_true
		end

		it "says who is the marchant for amazon" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.who_is_merchant.should eq("www.amazon.com")
		end
	end

	describe "initialize attribute for url fro api" do
		it "check whether the url is called is valid of invalid" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://yahoo.com"
			@tipsanity_instance.host_provider.should eq("yahoo.com")
		end
	end

	describe "amazon.com merchant initiator" do
		it "is amazon.com" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.is_merchant_amazon?{}.should == true
		end

		it "is not amazon.com" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.yahoo.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.is_merchant_amazon?{}.should == false
		end

		it "is path of amazon.com" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.merchant_amazon_path.should eq("/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05")
		end

		it "filter asin from given url" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.filtered_asin_from_amazon_path.should eq("B00CMQTVQO")
		end

		it "gets the product name from given url of amazon.com on the code gp" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			@tipsanity_instance.product_name.should eq("PlayStation 4 (PS4): Standard Edition")
		end

		it "gets the product name from given url of amazon.com on the code dp" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/Inferno-Novel-Robert-Langdon-ebook/dp/B00AXIZ4TQ/ref=pd_rhf_gw_s_ts_1_N8P4?ie=UTF8&refRID=0S1YP6CNWXFVPB12N8P4"
			@tipsanity_instance.product_name.should eq("Inferno: A Novel (Robert Langdon)")
		end
		
	end
end