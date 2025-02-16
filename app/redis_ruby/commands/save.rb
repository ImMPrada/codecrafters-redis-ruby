module RedisRuby
  module Commands
    class Save < Base
      def call(*_args)
        server.save_database
        resp_encoder('OK')
      end

      private

      def resp_encoder(message)
        client.write("+#{message}\r\n")
      end
    end
  end
end
