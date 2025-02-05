module RedisRuby
  module Commands
    class Base
      def initialize(client, data_store, server)
        @client = client
        @data_store = data_store
        @server = server
      end

      def call(*args)
        raise NotImplementedError
      end

      private

      attr_reader :client, :data_store, :server

      def resp_encoder(message)
        raise NotImplementedError
      end
    end
  end
end
