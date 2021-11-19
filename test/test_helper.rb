require "rubygems"
require 'dotenv'
require "minitest/autorun"
require "open_exchange_rates"

# Pick up ENV variables from .env file if exists
Dotenv.load

OpenExchangeRates.configuration.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']

