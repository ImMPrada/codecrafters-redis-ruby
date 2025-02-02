module RedisRuby
  module Commands
    class Get < Base
      def call(*args)
        key = args.first
        value = data_store[key]
        resp_encoder(value)
      end

      private

      def resp_encoder(message)
        client.write("$#{message.bytesize}\r\n#{message}\r\n")
      end
    end
  end
end
