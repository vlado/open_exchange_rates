# OpenExchangeRates

Ruby gem for [Open Exchange Rates API](http://openexchangerates.org) - free / open source hourly-updated currency data for everybody

## Installation

Add this line to your application's Gemfile:

    gem 'open_exchange_rates'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install open_exchange_rates

## Usage

Start by creating OpenExchangeRates::Rates instance

    fx = OpenExchangeRates::Rates.new

Convert between currencies using current rates    

    fx.convert(123.45, :from => "USD", :to => "EUR") # => 99.87
    
Convert between currencies on specific date   

    fx.convert(123.45, :from => "USD", :to => "EUR", :on => "2012-05-10") # => 95.47
    
Get current exchange rate

    fx.exchange_rate("USD", "EUR") # => 0.808996
    
Get exchange rate on specific date

    fx.exchange_rate("USD", "EUR", "2012-05-10") # => 0.808996

    
## TODO

- ability to pass Date as :on option (only 'yyyy-mm-dd' works currently)
- write some docs
- write more test for specific situations (invalid date, ...)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
