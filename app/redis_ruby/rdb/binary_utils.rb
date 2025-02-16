module RedisRuby
  module RDB
    module BinaryUtils
      def read_string(file)
        size = read_size(file)
        file.read(size)
      end

      def read_size(file)
        byte = file.read(1).unpack1('C')
        case byte >> 6
        when 0b00 then byte & 0x3F # Remaining 6 bits
        when 0b01 then (byte & 0x3F) << 8 | file.read(1).unpack1('C') # 14 bits
        when 0b10 then file.read(4).unpack1('N') # 32 bits
        else raise 'Unknown size type'
        end
      end
    end
  end
end
