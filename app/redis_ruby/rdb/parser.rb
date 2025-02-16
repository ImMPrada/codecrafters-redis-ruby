module RedisRuby
  module RDB
    class Parser
      include DatabaseReader
      include MetadataReader
      include HeaderReader
      include BinaryUtils

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
