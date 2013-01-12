require "open-uri"
require "date"

module OpenExchangeRates
  class Rates

    class MissingAppIdError < StandardError
      def initialize(msg = "Go to https://openexchangerates.org/signup to get App ID and then add it to the configuration: OpenExchangeRates.configuration.app_id = 'your app id'")
        super(msg)
      end
    end

    def initialize(options = {})
      @app_id = options[:app_id] || OpenExchangeRates.configuration.app_id
      raise MissingAppIdError unless @app_id
    end

    def exchange_rate(options = {})
      from_curr = options[:from].to_s.upcase
      to_curr = options[:to].to_s.upcase

      response = options[:on] ? on(options[:on]) : latest
      rates = response.rates

      from_curr = response.base_currency if from_curr.empty?
      to_curr = response.base_currency if to_curr.empty?

      if from_curr == to_curr
        rate = 1
      elsif from_curr == response.base_currency
        rate = rates[to_curr]
      elsif to_curr == response.base_currency
        rate = 1 / rates[from_curr]
      else
        rate = rates[to_curr] * (1 / rates[from_curr])
      end
      round(rate, 6)
    end

    def convert(amount, options = {})
      round(amount*exchange_rate(options))
    end

    def latest(reload = false)
      @latest_response = reload ? parse_latest : (@latest_response ||= parse_latest)
      OpenExchangeRates::Response.new(@latest_response)
    end
    
    def valid_yyyy_mm_dd(date_string)
      matches = date_string =~ /^([0-9]{4})(?:(1[0-2]|0[1-9])|-(1[0-2]|0[1-9])-)(3[0-1]|0[1-9]|[1-2][0-9])/
      raise ArgumentError, 'Not a valid date string (ie. yyyy-mm-dd)' unless matches
      date_string
    end
    
    def date_string_from(date_representation)
      if date_representation.kind_of? Date
        date_representation.to_s
      elsif date_representation.kind_of? String
        valid_yyyy_mm_dd date_representation
      else
        raise ArgumentError, "'on' must be a Date or 'yyyy-mm-dd' string"
      end
    end

    def on(date_representation)
      date_string = date_string_from(date_representation)
      OpenExchangeRates::Response.new(parse_on(date_string))
    end

    def round(amount, decimals = 2)
      (amount * 10**decimals).round.to_f / 10**decimals
    end

    def parse_latest
      @latest_parser ||= OpenExchangeRates::Parser.new
      @latest_parser.parse(open("#{OpenExchangeRates::LATEST_URL}?app_id=#{@app_id}"))
    end

    def parse_on(date_string)
      @on_parser = OpenExchangeRates::Parser.new
      @on_parser.parse(open("#{OpenExchangeRates::BASE_URL}/historical/#{date_string}.json?app_id=#{@app_id}"))
    end

  end
end