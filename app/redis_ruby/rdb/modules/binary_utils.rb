module RedisRuby
  module RDB
    module Modules
      module BinaryUtils
        def read_string(file)
          size = read_size(file)
          file.read(size)
        end

        def read_size(file)
          byte = file.read(1).unpack1('C')

          # Special format
          return file.read(4).unpack1('N') if [0xC0, 0xC1, 0xC2].include?(byte)

          # Length encoding
          case byte >> 6
          when 0b00 then byte & 0x3F # 6 bits
          when 0b01 then (byte & 0x3F) << 8 | file.read(1).unpack1('C') # 14 bits
          when 0b10 then file.read(4).unpack1('N') # 32 bits
          when 0b11 then byte & 0x3F # 6 bits (special case)
          end
        end
      end
    end
  end
end
