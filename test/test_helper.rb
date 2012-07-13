require "rubygems"
require "test/unit"
require "rr"
require "open_exchange_rates"

# Pick up ENV variables from .env file if exists
dot_env_file_path = File.expand_path("../../.env", __FILE__)
if File.exist?(dot_env_file_path)
  File.open(dot_env_file_path).each_line do |line|
    key, value = line.strip.split("=")
    ENV[key] = value unless key.nil? || value.nil?
  end
end

OpenExchangeRates.configuration.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end