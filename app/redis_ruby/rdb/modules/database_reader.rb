module RedisRuby
  module RDB
    module Modules
      module DatabaseReader
        def read_database(file)
          @data = {}

          loop do
            marker = file.read(1)&.unpack1('C')
            break if marker.nil?

            break if handle_marker(marker, file) == :eof
          end

          @data
        end

        private

        def handle_marker(marker, file)
          case marker
          when 0xFE # Start of a new DB
            db_index = read_size(file)
            puts "Reading DB ##{db_index}"
          when 0xFB # Hash table info
            read_size(file) # Total number of keys
            read_size(file) # Number of keys with expiration
          when 0x00 # Data type (String in this case)
            key = read_string(file)
            value = read_string(file)
            @data[key] = value
            puts "Key found: #{key} -> #{value}"
          when 0xFF # End of file
            :eof
          end
        end

        def read_expiration(file, marker)
          size = marker == 0xFD ? 4 : 8
          file.read(size) # We read the expiration but don't use it here
        end
      end
    end
  end
end
