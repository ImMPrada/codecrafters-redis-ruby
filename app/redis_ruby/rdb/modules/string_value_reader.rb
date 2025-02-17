module RedisRuby
  module RDB
    module Modules
      module StringValueReader
        # String Encodings
        ENCODING_INT8 = 0x00
        ENCODING_INT16 = 0x01
        ENCODING_INT32 = 0x02
        ENCODING_LZF = 0x03

        def handle_string_value(file)
          encoding = read_encoding(file)
          return if encoding.nil?

          read_value_by_encoding(file, encoding)
        end

        private

        def read_encoding(file)
          encoding = file.read(1)
          return nil if encoding.nil?

          encoding = encoding.unpack1('C')
          debug "String encoding: #{encoding}"
          encoding
        end

        def read_value_by_encoding(file, encoding)
          if encoding <= ENCODING_LZF
            read_encoded_value(file, encoding)
          else
            file.seek(-1, IO::SEEK_CUR)
            read_string(file)
          end
        end

        def read_encoded_value(file, encoding)
          case encoding
          when ENCODING_INT8 then read_int8(file)
          when ENCODING_INT16 then read_int16(file)
          when ENCODING_INT32 then read_int32(file)
          end
        end

        def read_int8(file)
          value = file.read(1)
          return if value.nil?

          value.unpack1('c').to_s
        end

        def read_int16(file)
          value = file.read(2)
          return if value.nil?

          value.unpack1('s>').to_s
        end

        def read_int32(file)
          value = file.read(4)
          return if value.nil?

          value.unpack1('l>').to_s
        end
      end
    end
  end
end
