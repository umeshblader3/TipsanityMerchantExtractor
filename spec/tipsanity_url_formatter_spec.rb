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
			TipsanityMerchantExtractor::AttributeExtractor.who_is_merchant("http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846").should eq("www.amazon.com")
		end

		# it "says available merchant" do
		# 	TipsanityMerchantExtractor::AttributeExtractor::REGISTERED_MERCHANT.should eq('{:amazon=>"www.amazon.com", :cjunction=>{:bestbuy=>"www.bestbuy.com"}, :link_share=>"www.linkshare.com"}')
		# end
	end

	describe "initialize attribute for url fro api" do
		it "check whether the url is called is valid of invalid" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://yahoo.com"
			@tipsanity_instance.host_provider.should eq("yahoo.com")
		end
	end

	describe "amazon.com merchant initiator" do
		it "is amazon.com" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			TipsanityMerchantExtractor::AttributeExtractor.is_merchant_amazon?("http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"){}.should == true
		end

		it "is not amazon.com" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.yahoo.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			TipsanityMerchantExtractor::AttributeExtractor.is_merchant_amazon?("http://www.yahoo.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"){}.should == false
		end

		it "is path of amazon.com" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846"
			TipsanityMerchantExtractor::AttributeExtractor.merchant_amazon_path("http://www.amazon.com/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-2&pf_rd_r=1B2CFTWGZGRQE19V8J1V&pf_rd_t=101&pf_rd_p=1263340922&pf_rd_i=507846").should eq("/gp/product/B00CMQTVQO/ref=s9_pop_gw_g63_ir05")
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

		it "gets the product final price from given url of amazon.com on the code dp" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.amazon.com/Inferno-Novel-Robert-Langdon-ebook/dp/B00AXIZ4TQ/ref=pd_rhf_gw_s_ts_1_N8P4?ie=UTF8&refRID=0S1YP6CNWXFVPB12N8P4"
			@tipsanity_instance.final_price.should eq(0.0)
		end
		
		it "extract the query from best buy" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"
			TipsanityMerchantExtractor::AttributeExtractor.extract_cj_bestbuy("http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"){|a, query| query}.should eq("id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1")
		end

		it "extract the product name from best buy" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"
			TipsanityMerchantExtractor::AttributeExtractor.extract_cj_bestbuy("http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"){|product_name, query| product_name.gsub("+", " ")}.should eq("Lens and LCD Screen Cleaning Cloth")
		end

		it "extract sku from query of bestbuy.com" do
			# @tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"
			TipsanityMerchantExtractor::AttributeExtractor.extract_cj_bestbuy("http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1"){|product_name, query| CGI.parse(query)["skuId"].first}.should eq("6732119")
		end

		it "get the product name from bestbuy" do
			@tipsanity_instance = TipsanityMerchantExtractor::AttributeExtractor.new "http://www.bestbuy.com/site/Lens+and+LCD+Screen+Cleaning+Cloth/6732119.p?id=1087340386022&skuId=6732119&st=6732119&cp=1&lp=1", cj: {developer_key:"008dc8f793ca7bd35171100e2ea7376f514b9345bb6844e689d908bedfadada0c6b8fed3b766913fa22ffdd97553498816471aff50c82cc847dae723ce535dbbe7/008928dbd03df651b41c8322a5212070709d82c7d78703f85d6bf698e7bb9516cd13a1a429cb8e35989291e7a7bbc600db8913a7e4687257f805186af6dd6627b9", website_id: "7191286"}
			@tipsanity_instance.product_name.should eql("DigiPower - Lens and LCD Screen Cleaning Cloth")
		end
	end
end