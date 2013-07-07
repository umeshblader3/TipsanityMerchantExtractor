# TipsanityMerchantExtractor [![Build Status](https://www.travis-ci.org/umeshblader3/TipsanityMerchantExtractor.png)](https://www.travis-ci.org/umeshblader3/TipsanityMerchantExtractor)

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'tipsanity_merchant_extractor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tipsanity_merchant_extractor

## Usage

Initiate a file with config/initializers/asin.rb

ASIN::Configuration.configure do |config|

  config.secret         = 'your secret'

  config.key            = 'your key'

  config.associate_tag  = 'your tag provided by amazon'

  config.version = 'version provided by amazon' # every details you can simply get from amazon profile.  
  
end

require 'httpi'
HTTPI.adapter = :httpclient
HTTPI.logger  = Rails.logger

Then start server and have some basic test.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request