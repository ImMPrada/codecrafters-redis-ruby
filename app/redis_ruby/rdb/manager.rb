module RedisRuby
  module RDB
    class Manager
      def initialize(dir, dbfilename)
        @dir = dir
        @dbfilename = dbfilename
        @rdb_path = File.join(dir, dbfilename)
      end

      def load_database
        return {} unless File.exist?(@rdb_path)

        read_database
      end

      def save_database(hash)
        write_database(hash)
      end

      private

      def read_database
        parser = Parser.new(@rdb_path)
        parser.parse
      end

      def write_database(hash)
        writer = Writer.new(@rdb_path)
        writer.write_rdb(hash)
      end
    end
  end
end
