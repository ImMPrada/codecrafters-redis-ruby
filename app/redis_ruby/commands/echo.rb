module RedisRuby
  module Commands
    class Echo < Base
      def call(*args)
        message = args.join(' ')
        resp_encoder(message)
      end

      private

      def resp_encoder(message)
        client.write("$#{message.bytesize}\r\n#{message}\r\n")
      end
    end
  end
end
