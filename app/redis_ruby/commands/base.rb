module RedisRuby
  module Commands
    class Base
      def initialize(client)
        @client = client
      end

      def call(*args)
        raise NotImplementedError
      end

      private

      attr_reader :client

      def resp_encoder(message)
        raise NotImplementedError
      end
    end
  end
end
