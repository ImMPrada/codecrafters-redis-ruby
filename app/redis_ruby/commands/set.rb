module RedisRuby
  module Commands
    class Set < Base
      def call(*args)
        var = {}
        @key, @value, @expiration_indicator, @expiration_value = args
        add_expiration(var)

        var[:value] = value

        data_store[key] = var
        puts("data_store: #{data_store}")
        client.puts(resp_encoder('+OK'))
      end

      private

      attr_reader :key, :value, :expiration_indicator, :expiration_value

      def resp_encoder(message)
        "#{message}\r\n"
      end

      def add_expiration(var)
        return unless expiration_indicator && expiration_value
        raise "Unknown expiration indicator: #{expiration_indicator}" unless expiration_indicator == 'px'

        var[:xp] = ((Time.now + (expiration_value.to_i / 1000.0)).to_f * 1000).to_i
      end
    end
  end
end
