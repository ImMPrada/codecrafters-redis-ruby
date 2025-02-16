module RedisRuby
  module Commands
    class Keys < Base
      def call(*args)
        return client.write("*0\r\n") if args.empty?

        pattern = args.first
        resp_encoder(pattern)
      end

      private

      def resp_encoder(pattern)
        matching_keys = keys(pattern)
        client.write("*#{matching_keys.size}\r\n")
        matching_keys.each do |key|
          client.write("$#{key.bytesize}\r\n#{key}\r\n")
        end
      end

      def keys(pattern)
        return data_store.keys if pattern == '*'

        []
      end
    end
  end
end
