# OpenExchangeRates

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/vlado/open_exchange_rates)

Ruby gem for currency conversion based on [Open Exchange Rates API](http://openexchangerates.org) - free / open source hourly-updated currency data for everybody

## Accuracy

Please see [https://github.com/currencybot/open-exchange-rates/#accuracy](https://github.com/currencybot/open-exchange-rates/#accuracy) and/or [http://openexchangerates.org/documentation/#specification](http://openexchangerates.org/documentation/#specification)

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

    fx.exchange_rate(:from => "USD", :to => "EUR") # => 0.808996
    
Get exchange rate on specific date

    fx.exchange_rate(:from => "USD", :to => "EUR", :on => "2012-05-10") # => 0.773329
    
### Default currency

If you omit **:from** or **:to** option conversion will be related to base currency. USD is set as base currency (plan is to add this as config option in the near future).

    fx.convert(123.45, :to => "EUR") # => 99.87 EUR
    fx.convert(123.45, :from => "EUR") # => 152.51 USD

    fx.exchange_rate(:to => "EUR") # => 0.808996
    fx.exchange_rate(:from => "EUR") # => 1.235414

    
## TODO

- ability to set default currency (USD is currently always set as base currency)
- ability to pass Date as :on option (only 'yyyy-mm-dd' works currently)
- write some docs
- write more test for specific situations (invalid date, ...)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Licence and Terms

Licence - [http://openexchangerates.org/license](http://openexchangerates.org/license)
Terms - [http://openexchangerates.org/terms](http://openexchangerates.org/terms)
