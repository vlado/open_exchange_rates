module OpenExchangeRates
  module Cache
    class MissingRequiredOption < StandardError
      def initialize(keys)
        super("Missing required option(s): #{keys.join(', ')}")
      end
    end

    class Base
      def initialize(options={})
      end

      def key(options={})
        ['open-exchange-rates', options[:on], options[:from]].compact.join(':')
      end

      def get(key)
        nil
      end

      def set(key, value)
        value
      end
    end

    class NullCache < Base
    end

    class MemoryCache < Base
      def initialize(options={})
        @tc = Thread.current
      end

      def get(key)
        @tc[key]
      end

      def set(key, value)
        @tc[key] = value
      end
    end

    class CustomCache < Base
      def initialize(options={})
        raise MissingRequiredOption.new(:client) unless options.include?(:client)
        @client = options[:client]
      end

      def get(key)
        @client.get(key)
      end

      def set(key, value)
        @client.set(key, value)
      end
    end
  end
end
