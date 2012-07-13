require "test_helper"

class TestOpenExchangeRates < Test::Unit::TestCase

  def test_app_id_is_required
    assert_nothing_raised { OpenExchangeRates::Rates.new }

    stub(OpenExchangeRates.configuration).app_id { nil }
    assert_raise(OpenExchangeRates::Rates::MissingAppIdError) { OpenExchangeRates::Rates.new }

    assert_nothing_raised { OpenExchangeRates::Rates.new(:app_id => "myappid") }

    OpenExchangeRates.configuration.app_id = ENV['OPEN_EXCHANGE_RATES_APP_ID']
  end

  def test_invalid_app_id_raise_error
    stub(OpenExchangeRates.configuration).app_id { "somethingstupid" }
    fx = OpenExchangeRates::Rates.new

    assert_raise NoMethodError do
      fx.exchange_rate(:from => "USD", :to => "EUR")
    end
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
    assert_equal 0.991118, on_rates.rates["AUD"]
    assert_equal 5.795542, on_rates.rates["HRK"]
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

private

  def assets_root
    File.join(File.dirname(__FILE__), "assets")
  end

  def open_asset(filename)
    File.open("#{assets_root}/#{filename}")
  end

end