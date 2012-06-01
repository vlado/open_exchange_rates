require "test_helper"

class TestOpenExchangeRates < Test::Unit::TestCase

  def test_exchange_rate
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(File.open("latest.json")) }

    # 1 USD = 6.0995 HRK
    # 1 USD = 1.026057 AUD
    assert_equal 1, fx.exchange_rate("USD", "USD")
    assert_equal 1, fx.exchange_rate("AUD", "AUD")
    assert_equal 1, fx.exchange_rate("HRK", "HRK")

    assert_equal 6.0995, fx.exchange_rate("USD", "HRK")
    assert_equal 1.026057, fx.exchange_rate("USD", "AUD")

    assert_equal 0.163948, fx.exchange_rate("HRK", "USD")
    assert_equal 0.974605, fx.exchange_rate("AUD", "USD")

    assert_equal 5.944602, fx.exchange_rate("AUD", "HRK")
    assert_equal 0.168220, fx.exchange_rate("HRK", "AUD")
  end

  def test_convert
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(File.open("latest.json")) }

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
    stub(fx).parse_on { OpenExchangeRates::Parser.new.parse(File.open("2012-05-10.json")) }

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

    assert_raise OpenExchangeRates::Rates::MissingFromOptionError do
      fx.convert(100, :to => "HRK")
    end
  end

  def test_convert_if_to_option_is_missing
    fx = OpenExchangeRates::Rates.new
    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(File.open("latest.json")) }

    # Defaults to base currency (USD)
    # 1 USD = 6.0995 HRK
    assert_equal 16.39, fx.convert(100, :from => "HRK")
  end

  def test_latest
    fx = OpenExchangeRates::Rates.new
    latest_rates = fx.latest

    assert_equal "USD", latest_rates.base_currency
    assert_equal "USD", latest_rates.base
    assert latest_rates.rates.is_a?(Hash)

    stub(fx).parse_latest { OpenExchangeRates::Parser.new.parse(File.open("latest.json")) }

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
    assert on_rates.rates.is_a?(Hash)

    assert_equal 1, on_rates.rates["USD"]
    assert_equal 0.99458, on_rates.rates["AUD"]
    assert_equal 5.80025, on_rates.rates["HRK"]
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
    fx.convert(123, :from => "EUR", :to => "AUD", :on => "2012-03-10")
    fx.convert(100, :from => "USD", :to => "EUR")
    fx.convert(123.45, :from => "EUR", :to => "USD", :on => "2012-04-10")
    fx.convert(12, :from => "USD", :to => "EUR")
    fx.convert(123.4567, :from => "EUR", :to => "USD", :on => "2012-05-10")
  end

end