module RedisRuby
  module RDB
    class Writer
      include Modules::HeaderWriter
      include Modules::FooterWriter
      include Modules::MetadataWriter
      include Modules::DatabaseWriter

      DB_START = 0xFE

      def initialize(output_path)
        @file = File.open(output_path, 'wb')
      end

      def write_rdb(hash)
        write_header
        write_metadata('redis-ver', '6.0.16')

        # If hash is not empty, write the database
        write_database(hash) unless hash.empty?

        write_footer
      ensure
        @file.close
      end
    end
  end
end
