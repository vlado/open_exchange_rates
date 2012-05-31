module OpenExchangeRates
  class Response

    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data
    end

    def rates
      raw_data["rates"]
    end

    def base_currency
      raw_data["base"]
    end
    alias :base :base_currency

  end
end