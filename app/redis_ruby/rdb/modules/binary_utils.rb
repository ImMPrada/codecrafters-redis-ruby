module RedisRuby
  module RDB
    module Modules
      module BinaryUtils
        def read_string(file)
          size = read_size(file)
          return nil if size.nil?

          value = file.read(size)
          raise "Failed to read string of length #{size}" if value.nil?

          value.force_encoding('UTF-8')
        end

        def read_size(file)
          byte = file.read(1)
          return nil if byte.nil?

          byte = byte.unpack1('C')
          handle_size_encoding(file, byte)
        end

        private

        def handle_size_encoding(file, byte)
          case byte >> 6
          when 0b00, 0b11 # 6 bits
            byte & 0x3F
          when 0b01 # 14 bits
            read_14bit_size(file, byte)
          when 0b10 # 32 bits
            read_32bit_size(file)
          end
        end

        def read_14bit_size(file, byte)
          next_byte = file.read(1)
          return nil if next_byte.nil?

          ((byte & 0x3F) << 8) | next_byte.unpack1('C')
        end

        def read_32bit_size(file)
          value = file.read(4)
          return nil if value.nil?

          value.unpack1('N')
        end

        def debug(message)
          puts message if @debug
        end
      end
    end
  end
end
