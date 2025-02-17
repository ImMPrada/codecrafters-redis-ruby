module RedisRuby
  module Commands
    class Get < Base
      def call(*args)
        @now = Time.now
        @key, = args

        respond
      end

      private

      attr_reader :now, :key

      def respond
        var = data_store[key]
        return nil_response if var.nil?

        if var[:xp] && (Time.now.to_f * 1000).to_i > var[:xp]
          data_store.delete(key)
          return nil_response
        end

        resp_encoder(var[:value])
      end

      def resp_encoder(message)
        client.write("$#{message.bytesize}\r\n#{message}\r\n")
      end

      def nil_response
        client.write("$-1\r\n")
      end
    end
  end
end
