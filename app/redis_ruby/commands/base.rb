module RedisRuby
  module Commands
    class Base
      def initialize(client)
        @client = client
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :client

      def resp_encoder(message)
        "#{message}\r\n"
      end
    end
  end
end
