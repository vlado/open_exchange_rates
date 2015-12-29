# OpenExchangeRates

[![Code Climate](https://codeclimate.com/github/vlado/open_exchange_rates.png)](https://codeclimate.com/github/vlado/open_exchange_rates)
[![Gem Version](https://badge.fury.io/rb/open_exchange_rates.png)](http://badge.fury.io/rb/open_exchange_rates)

Ruby gem for currency conversion based on [Open Exchange Rates API](http://openexchangerates.org) - free / open source hourly-updated currency data for everybody

## Accuracy

Please see [https://github.com/josscrowcroft/open-exchange-rates#accuracy](https://github.com/josscrowcroft/open-exchange-rates#accuracy)

## Installation

Add this line to your application's Gemfile:

    gem 'open_exchange_rates'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install open_exchange_rates

## Configuration

You will need App ID to use OpenExchangeRates, you can get one [here](https://openexchangerates.org/signup/) for [free](https://openexchangerates.org/signup/free).

**Option 1**

Set OPEN_EXCHANGE_RATES_APP_ID environment variable and it will be used automatically. If you are using [foreman](http://ddollar.github.com/foreman/) for example just add it to your .env file like this

    OPEN_EXCHANGE_RATES_APP_ID=YourAppID

**Option 2**

    OpenExchangeRates.configure do |config|
      config.app_id = "YourAppID"
    end

If you are using Rails good place to add this is config/initializers/open_exchange_rates.rb

**Option 3**

Pass it on initialization

    fx = OpenExchangeRates::Rates.new(:app_id => "YourAppID")


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

### Caching queries

Historical exchange rate queries can be cached to improve performance. Bundled
cache adapters include a `MemoryCache` and a `CustomCache`. To enable query
caching, configure it or pass a hash of cache options to the initializer:

    OpenExchangeRates.configure do |config|
      config.app_id = "YourAppID"
      config.cache.type = "custom"
      config.cache.client = Redis.new(url: 'redis://localhost:6379')
    end

The memory cache requires no configuration. A custom cache requires a client
object, which can be anything that responds to `get` and `set`.

## TODO

- ability to set default currency (USD is currently always set as base currency)
- <del>ability to pass Date as :on option (only 'yyyy-mm-dd' works currently)</del>
- write some docs
- write more test for specific situations (<del>invalid date</del>, ...)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Running tests

1. Copy env.example to .env `cp env.example .env`
2. Open `.env` and enter your API ID
3. Run `rake`


## Licence and Terms

This project rocks and uses MIT-LICENSE.

Please check Open Exchange Rates API [license](http://openexchangerates.org/license) and [terms](http://openexchangerates.org/terms) also.
