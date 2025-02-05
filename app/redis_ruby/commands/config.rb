module RedisRuby
  module Commands
    class Config < Base
      def call(*args)
        return if args.empty?

        config_command, config_value = args
        send(config_command.downcase, config_value)
      end

      private

      def get(key)
        value = server.send(key)
        resp_encoder(key, value)
      end

      def resp_encoder(key, value)
        client.write("*2\r\n$#{key.bytesize}\r\n#{key}\r\n$#{value.bytesize}\r\n#{value}\r\n")
      end
    end
  end
end
