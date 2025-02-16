module RedisRuby
  module RDB
    module Modules
      module MetadataWriter
        HASH_TABLE_INFO = 0x04

        def write_metadata(key, value)
          @file.write([HASH_TABLE_INFO].pack('C'))
          write_length_encoding(key.length)
          @file.write(key)
          write_length_encoding(value.length)
          @file.write(value)
        end

        private

        def write_length_encoding(length)
          if length < 64
            @file.write([length].pack('C')) # 6 bits
          elsif length < 16_384
            @file.write([0x40 | (length >> 8), length & 0xFF].pack('CC')) # 14 bits
          else
            @file.write(
              [0x80 | (length >> 24), (length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF].pack('CCCC')
            ) # 32 bits
          end
        end
      end
    end
  end
end
