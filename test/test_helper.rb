require "rubygems"
require "test/unit"
require "rr"
require "open_exchange_rates"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end