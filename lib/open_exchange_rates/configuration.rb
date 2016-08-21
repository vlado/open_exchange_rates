module OpenExchangeRates
  class Configuration
    attr_accessor :app_id

    def cache
      @cache ||= CacheConfiguration.new
    end

    def cache=(c)
      @cache = c
    end
  end

  class CacheConfiguration
    attr_accessor :type, :client

    def type
      @type || 'null'
    end

    def to_hash
      { type: type, client: client }.select { |k, v| !v.nil? }
    end
  end
end
