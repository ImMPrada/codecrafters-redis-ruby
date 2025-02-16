module RedisRuby
  module RDB
    class Parser
      include Modules::DatabaseReader
      include Modules::MetadataReader
      include Modules::HeaderReader
      include Modules::BinaryUtils

      def initialize(file_path)
        @file_path = file_path
        @data = {} # Here we'll store the extracted data
      end

      def parse
        File.open(@file_path, 'rb') do |file|
          read_header(file)
          read_metadata(file)
          read_database(file)
        end

        @data
      end
    end
  end
end
