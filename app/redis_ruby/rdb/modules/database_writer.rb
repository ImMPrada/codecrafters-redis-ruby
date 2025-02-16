module RedisRuby
  module RDB
    module Modules
      module DatabaseWriter
        def write_database(hash)
          @file.write([0xFE].pack('C')) # FE indicates start of database
          write_size(0) # Database index (0 by default)

          @file.write([0xFB].pack('C')) # FB indicates hash table info
          write_size(hash.size) # Total number of keys
          write_size(0) # Number of keys with expiration (0 in this case)

          hash.each do |key, value|
            @file.write([0x00].pack('C')) # Data type "String"
            write_string(key)
            write_string(value)
          end
        end

        private

        def write_string(str)
          write_size(str.bytesize)
          @file.write(str)
        end

        def write_size(size)
          if size < 64
            @file.write([size].pack('C')) # Remaining 6 bits can store size directly
          elsif size < 16_384
            @file.write([0x40 | (size >> 8), size & 0xFF].pack('CC')) # 14 bits
          else
            @file.write([0x80].pack('C')) # 4 byte prefix
            @file.write([size].pack('N')) # 32-bit integer (big-endian)
          end
        end
      end
    end
  end
end
