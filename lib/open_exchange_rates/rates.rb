require "open-uri"

module OpenExchangeRates
  class Rates

    class MissingFromOptionError < StandardError; end;

    def exchange_rate(from, to, on = nil)
      from = from.to_s.upcase
      to = to.to_s.upcase

      response = on ? on(on) : latest
      rates = response.rates

      if from == to
        rate = 1
      elsif from == response.base_currency
        rate = rates[to]
      elsif to == response.base_currency
        rate = 1 / rates[from]
      else
        rate = rates[to] * (1 / rates[from])
      end
      round(rate, 6)
    end

    def convert(amount, options = {})
      from_curr = options[:from].to_s.upcase
      raise MissingFromOptionError if from_curr.empty?

      response = options[:on] ? on(options[:on]) : latest
      rates = response.rates

      to_curr = options[:to].to_s.upcase
      to_curr = response.base_currency if to_curr.empty?

      from_rate = rates[from_curr].to_f
      to_rate = rates[to_curr].to_f

      round( amount * ( to_rate * (1 / from_rate) ) )
    end

    def latest(reload = false)
      @latest_response = reload ? parse_latest : (@latest_response ||= parse_latest)
      OpenExchangeRates::Response.new(@latest_response)
    end

    def on(date_string)
      OpenExchangeRates::Response.new(parse_on(date_string))
    end

    def round(amount, decimals = 2)
      (amount * 10**decimals).round.to_f / 10**decimals
    end

    def parse_latest
      @latets_parser ||= OpenExchangeRates::Parser.new
      @latets_parser.parse(open(OpenExchangeRates::LATEST_URL))
    end

    def parse_on(date_string)
      @on_parser = OpenExchangeRates::Parser.new
      @on_parser.parse(open("#{OpenExchangeRates::BASE_URL}/historical/#{date_string}.json"))
    end

  end
end