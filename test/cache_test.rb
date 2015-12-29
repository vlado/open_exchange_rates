require 'test_helper'

class TestOpenExchangeRates < Test::Unit::TestCase
  def test_cache_key
    cache = OpenExchangeRates::Cache::MemoryCache.new
    assert_equal 'open-exchange-rates:2015-12-27:USD', cache.key(:from => 'USD', :on => '2015-12-27')
  end

  def test_cache_set_returns_value_for_null_adapter
    cache = OpenExchangeRates::Cache::MemoryCache.new
    assert_equal 'value', cache.set('key', 'value')
    assert_equal 'value', cache.get('key')
  end

  def test_cache_get_returns_nil_for_null_adapter
    cache = OpenExchangeRates::Cache::MemoryCache.new
    assert_equal nil, cache.get('key')
  end
end
