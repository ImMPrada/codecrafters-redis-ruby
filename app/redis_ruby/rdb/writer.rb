module RedisRuby
  module RDB
    class Writer
      include Modules::HeaderWriter
      include Modules::FooterWriter
      include Modules::MetadataWriter
      include Modules::DatabaseWriter

      MAGIC_HEADER = 'REDIS0011'.freeze
      DB_START = 0xFE
      EOF_MARKER = 0xFF
      HASH_TABLE_INFO = 0xFB

      def initialize(output_path)
        @file = File.open(output_path, 'wb')
      end

      def write_rdb(hash)
        write_header
        write_metadata('redis-ver', '6.0.16')
        write_database(hash)
        write_footer
      ensure
        @file.close
      end
    end
  end
end
