module RedisRuby
  module RDB
    module Modules
      module DatabaseWriter
        # Value Types
        TYPE_STRING = 0

        # String Encodings
        ENCODING_INT8 = 0
        ENCODING_INT16 = 1
        ENCODING_INT32 = 2

        # Special Opcodes
        SELECT_DB = 0xFE
        EXPIRETIME_MS = 0xFC
        DB_NUMBER = 0

        def write_database(hash)
          @file.write([SELECT_DB].pack('C'))
          write_length_encoding(DB_NUMBER)

          hash.each do |key, value_hash|
            write_key_value_pair(key, value_hash)
          end
        end

        private

        def write_key_value_pair(key, value_hash)
          # Write expiry if present
          if value_hash[:xp]
            @file.write([EXPIRETIME_MS].pack('C'))
            @file.write([value_hash[:xp]].pack('Q>')) # 8-byte unsigned long, big-endian
          end

          # Write key
          write_length_encoding(key.length)
          @file.write(key)

          # Write value type
          @file.write([TYPE_STRING].pack('C'))

          # Write the actual value
          case value_hash[:value]
          when Integer
            write_integer_value(value_hash[:value])
          when String
            write_string_value(value_hash[:value])
          else
            # Default to string representation
            write_string_value(value_hash[:value].to_s)
          end
        end

        def write_integer_value(number)
          if number >= -128 && number <= 127
            @file.write([ENCODING_INT8].pack('C'))
            @file.write([number].pack('c'))
          elsif number >= -32_768 && number <= 32_767
            @file.write([ENCODING_INT16].pack('C'))
            @file.write([number].pack('s>'))
          elsif number >= -2_147_483_648 && number <= 2_147_483_647
            @file.write([ENCODING_INT32].pack('C'))
            @file.write([number].pack('l>'))
          else
            # For numbers outside these ranges, store as string
            write_string_value(number.to_s)
          end
        end

        def write_string_value(str)
          write_length_encoding(str.length)
          @file.write(str)
        end

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
