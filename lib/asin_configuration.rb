require 'httpi'
require 'asin'
HTTPI.adapter = :httpclient

ASIN::Configuration.configure do |config|
	config.secret = 'your secret'
	config.key            = 'your key'
  config.associate_tag  = 'tipsanity-20'
  config.version = '2011-08-01'
end