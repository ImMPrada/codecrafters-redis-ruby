module RedisRuby
  module Commands
    class Base
      def initialize(client, data_store)
        @client = client
        @data_store = data_store
      end

      def call(*args)
        raise NotImplementedError
      end

      private

      attr_reader :client, :data_store

      def resp_encoder(message)
        raise NotImplementedError
      end
    end
  end
end
