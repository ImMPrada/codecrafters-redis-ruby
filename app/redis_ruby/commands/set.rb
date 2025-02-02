module RedisRuby
  module Commands
    class Set < Base
      def call(*args)
        key, value = args
        data_store[key] = value
        client.puts(resp_encoder('+OK'))
      end

      private

      def resp_encoder(message)
        "#{message}\r\n"
      end
    end
  end
end
