require "test_helper"
require 'complex'

class TestOpenExchangeRates < Test::Unit::TestCase

  def test_app_id_is_required
    assert_nothing_raised { OpenExchangeRates::Rates.new }

    stub(OpenExchangeRates.configuration).app_id { nil }
    assert_raise(OpenExchangeRates::Rates::MissingAppIdError) { OpenExchangeRates::Rates.new }

    assert_nothing_raised { OpenExchangeRates::Rates.new(:app_id => "myappid") }

    OpenExchangeRates.configuration.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']
  end

  def test_app_id_configuration
    fx = OpenExchangeRates::Rates.new
    assert_equal ENV['OPEN_EXCHANGE_RATES_APP_ID'], fx.app_id

    OpenExchangeRates.configure do |config|
      config.app_id = "myappid"
    end
    fx = OpenExchangeRates::Rates.new
    assert_equal "myappid", fx.app_id

    fx = OpenExchangeRates::Rates.new(:app_id => 'myotherappid')
    assert_equal "myotherappid", fx.app_id

    OpenExchangeRates.configuration.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']
  end

  def test_invalid_app_id_raise_error
    stub(OpenExchangeRates.configuration).app_id { "somethingstupid" }
    fx = OpenExchangeRates::Rates.new

    assert_raise OpenURI::HTTPError do
      fx.exchange_rate(:from => "USD", :to => "EUR")
    end
  end

  def test_default_cache_is_null
    fx = OpenExchangeRates::Rates.new
    assert_equal OpenExchangeRates::Cache::NullCache, fx.cache.class
  end

  def test_cache_type_configuration
    fx = OpenExchangeRates::Rates.new(cache: { type: :memory })
    assert_equal OpenExchangeRates::Cache::MemoryCache, fx.cache.class
  end

  def test_exchange_rate
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(open_asset("latest.json")) }

    # 1 USD = 6.0995 HRK
    # 1 USD = 1.026057 AUD
    assert_equal 1, fx.exchange_rate(:from => "USD", :to => "USD")
    assert_equal 1, fx.exchange_rate(:from => "AUD", :to => "AUD")
    assert_equal 1, fx.exchange_rate(:from => "HRK", :to => "HRK")

    assert_equal 6.0995, fx.exchange_rate(:from => "USD", :to => "HRK")
    assert_equal 1.026057, fx.exchange_rate(:from => "USD", :to => "AUD")

    assert_equal 0.163948, fx.exchange_rate(:from => "HRK", :to => "USD")
    assert_equal 0.974605, fx.exchange_rate(:from => "AUD", :to => "USD")

    assert_equal 5.944602, fx.exchange_rate(:from => "AUD", :to => "HRK")
    assert_equal 0.168220, fx.exchange_rate(:from => "HRK", :to => "AUD")

    assert_equal 0.00023, fx.exchange_rate(:from => 'SLL', to: 'USD')
    assert_equal 4350, fx.exchange_rate(:from => 'USD', to: 'SLL')
  end

  def test_exchange_rate_on_specific_date
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_on { OpenExchangeRates::Parser.new.parse(open_asset("2012-05-10.json")) }

    # 1 USD = 5.80025 HRK
    # 1 USD = 0.99458 AUD
    assert_equal 1, fx.exchange_rate(:from => "USD", :to => "USD", :on => "2012-05-10")
    assert_equal 1, fx.exchange_rate(:from => "AUD", :to => "AUD", :on => "2012-05-10")
    assert_equal 1, fx.exchange_rate(:from => "HRK", :to => "HRK", :on => "2012-05-10")

    assert_equal 5.80025, fx.exchange_rate(:from => "USD", :to => "HRK", :on => "2012-05-10")
    assert_equal 0.99458, fx.exchange_rate(:from => "USD", :to => "AUD", :on => "2012-05-10")

    assert_equal 0.172406, fx.exchange_rate(:from => "HRK", :to => "USD", :on => "2012-05-10")
    assert_equal 1.005450, fx.exchange_rate(:from => "AUD", :to => "USD", :on => "2012-05-10")

    assert_equal 5.831859, fx.exchange_rate(:from => "AUD", :to => "HRK", :on => "2012-05-10")
    assert_equal 0.171472, fx.exchange_rate(:from => "HRK", :to => "AUD", :on => "2012-05-10")
  end

  def test_exchange_rate_on_specific_date_specified_by_date_class
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_on { OpenExchangeRates::Parser.new.parse(open_asset("2012-05-10.json")) }

    assert_equal 1, fx.exchange_rate(:from => "USD", :to => "USD", :on => Date.new(2012,05,10))
  end

  def test_exchange_requires_valid_date
    fx = OpenExchangeRates::Rates.new

    assert_raise ArgumentError do
      fx.exchange_rate(:from => "USD", :to => "USD", :on => "somethingstupid")
    end

    assert_raise ArgumentError do
      fx.exchange_rate(:from => "USD", :to => "USD", :on => Complex(0.3))
    end
  end

  def test_convert
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(open_asset("latest.json")) }

    # 1 USD = 6.0995 HRK
    # 1 USD = 1.026057 AUD
    assert_equal 609.95, fx.convert(100, :from => "USD", :to => "HRK")
    assert_equal 16.39, fx.convert(100, :from => "HRK", :to => "USD")
    assert_equal 120.32, fx.convert(123.4567, :from => "AUD", :to => "USD")
    assert_equal 733.90, fx.convert(123.4567, :from => "AUD", :to => "HRK")
    assert_equal 20.77, fx.convert(123.4567, :from => "HRK", :to => "AUD")
  end

  def test_convert_on_specific_date
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_on { OpenExchangeRates::Parser.new.parse(open_asset("2012-05-10.json")) }

    # 1 USD = 5.80025 HRK
    # 1 USD = 0.99458 AUD
    assert_equal 580.03, fx.convert(100, :from => "USD", :to => "HRK", :on => "2012-10-05")
    assert_equal 17.24, fx.convert(100, :from => "HRK", :to => "USD", :on => "2012-10-05")
    assert_equal 124.13, fx.convert(123.4567, :from => "AUD", :to => "USD", :on => "2012-10-05")
    assert_equal 719.98, fx.convert(123.4567, :from => "AUD", :to => "HRK", :on => "2012-10-05")
    assert_equal 21.17, fx.convert(123.4567, :from => "HRK", :to => "AUD", :on => "2012-10-05")
  end

  def test_convert_if_from_option_is_missing
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(open_asset("latest.json")) }

    # from defaults to base currency (USD)
    # 1 USD = 6.0995 HRK
    # 1 USD = 1.026057 AUD
    assert_equal 609.95, fx.convert(100, :to => "HRK")
    assert_equal 102.61, fx.convert(100, :to => "AUD")
  end

  def test_convert_if_to_option_is_missing
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(open_asset("latest.json")) }

    # to defaults to base currency (USD)
    # 1 USD = 6.0995 HRK
    # 1 USD = 1.026057 AUD
    assert_equal 16.39, fx.convert(100, :from => "HRK")
    assert_equal 97.46, fx.convert(100, :from => "AUD")
  end

  def test_latest
    fx = OpenExchangeRates::Rates.new
    latest_rates = fx.latest

    assert_equal "USD", latest_rates.base_currency
    assert_equal "USD", latest_rates.base
    assert latest_rates.rates.is_a?(Hash)

    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(open_asset("latest.json")) }

    # latest results are cached
    cached_rates = fx.latest
    assert_equal latest_rates.rates["USD"], cached_rates.rates["USD"]
    assert_equal latest_rates.rates["AUD"], cached_rates.rates["AUD"]
    assert_equal latest_rates.rates["HRK"], cached_rates.rates["HRK"]

    # latest results are reloaded
    stubbed_rates = fx.latest(:reload)
    assert_equal latest_rates.rates["USD"], stubbed_rates.rates["USD"]
    assert_not_equal latest_rates.rates["AUD"], stubbed_rates.rates["AUD"]
    assert_not_equal latest_rates.rates["HRK"], stubbed_rates.rates["HRK"]

    assert_equal 1, stubbed_rates.rates["USD"]
    assert_equal 1.026057, stubbed_rates.rates["AUD"]
    assert_equal 6.0995, stubbed_rates.rates["HRK"]
  end

  def test_on
    fx = OpenExchangeRates::Rates.new
    on_rates = fx.on("2012-05-10")

    assert_equal "USD", on_rates.base_currency
    assert_equal "USD", on_rates.base

    assert_equal 1, on_rates.rates["USD"]
    assert_equal 0.989596, on_rates.rates["AUD"]
    assert_equal 5.793188, on_rates.rates["HRK"]
  end

  def test_round
    fx = OpenExchangeRates::Rates.new

    assert_equal 12.35, fx.round(12.345)
    assert_equal 1.23, fx.round(1.2345)
    assert_equal 1.2, fx.round(1.2345, 1)
    assert_equal 12.3457, fx.round(12.345678, 4)
  end

  def test_multiple_calls
    fx = OpenExchangeRates::Rates.new

    assert_nothing_raised do
      fx.convert(123, :from => "EUR", :to => "AUD", :on => "2012-03-10")
      fx.convert(100, :from => "USD", :to => "EUR")
      fx.convert(123.45, :from => "EUR", :to => "USD", :on => "2012-04-10")
      fx.convert(12, :from => "USD", :to => "EUR")
      fx.convert(123.4567, :from => "EUR", :to => "USD", :on => "2012-05-10")
      fx.exchange_rate(:from => "USD", :to => "EUR")
      fx.exchange_rate(:from => "USD", :to => "EUR", :on => "2012-04-10")
      fx.exchange_rate(:from => "USD", :to => "AUD", :on => "2012-05-10")
    end
  end

  def test_invalid_currency_code_fails_with_rate_not_found_error
    fx = OpenExchangeRates::Rates.new

    assert_raise(OpenExchangeRates::Rates::RateNotFoundError) do
      fx.exchange_rate(:from => "???", :to => "AUD", :on => "2012-05-10")
    end

    assert_raise(OpenExchangeRates::Rates::RateNotFoundError) do
      fx.exchange_rate(:from => "USD", :to => "???", :on => "2012-05-10")
    end
  end

  def test_exchange_rate_set_not_cached
    cache = OpenExchangeRates::Cache::MemoryCache.new
    stub(cache).get { nil }
    stub(cache).set { open_asset('2012-05-10.json') }

    fx = OpenExchangeRates::Rates.new(cache: { type: :memory })
    fx.cache = cache

    fx.parse_on("2012-05-10")
    assert_received(cache) { |o| o.set('open-exchange-rates:2012-05-10', anything) }
  end

  def test_exchange_rate_get_cached
    cache = OpenExchangeRates::Cache::MemoryCache.new
    stub(cache).get('open-exchange-rates:2012-05-10') { open_asset("2012-05-10.json") }
    dont_allow(cache) { |o| o.set }

    fx = OpenExchangeRates::Rates.new
    fx.cache = cache

    fx.parse_on("2012-05-10")
  end

private

  def assets_root
    File.join(File.dirname(__FILE__), "assets")
  end

  def open_asset(filename)
    File.open("#{assets_root}/#{filename}")
  end

end
