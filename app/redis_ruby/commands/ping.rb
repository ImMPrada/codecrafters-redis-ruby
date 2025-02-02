module RedisRuby
  module Commands
    class Ping < Base
      def call(*_args)
        client.puts(resp_encoder('+PONG'))
      end

      private

      def resp_encoder(message)
        "#{message}\r\n"
      end
    end
  end
end
