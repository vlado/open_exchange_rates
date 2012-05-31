require "rubygems"
require "open_exchange_rates/version"
require "open_exchange_rates/parser"
require "open_exchange_rates/response"
require "open_exchange_rates/rates"

module OpenExchangeRates
  BASE_URL = "http://openexchangerates.org"
  LATEST_URL = "#{BASE_URL}/latest.json"
end
