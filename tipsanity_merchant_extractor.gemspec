# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tipsanity_merchant_extractor/version'

Gem::Specification.new do |gem|
  gem.name          = "tipsanity_merchant_extractor"
  gem.version       = TipsanityMerchantExtractor::VERSION
  gem.authors       = ["Umesh Umesh"]
  gem.email         = ["umeshblader@gmail.com"]
  gem.description   = %q{Tipsanity website uses this gem to extract their marchant related information}
  gem.summary       = %q{registered marchant related information.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "asin"
  gem.add_development_dependency "httpclient"
end
