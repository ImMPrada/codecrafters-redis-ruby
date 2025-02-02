module RedisRuby
  module Commands
    class Ping < Base
      def call
        client.puts(resp_encoder('+PONG'))
      end
    end
  end
end

