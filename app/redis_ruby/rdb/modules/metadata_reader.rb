module RedisRuby
  module RDB
    module Modules
      module MetadataReader
        def read_metadata(file)
          loop do
            marker = file.read(1)&.unpack1('C')
            break unless marker == 0xFA # FA indicates metadata

            key = read_string(file)
            value = read_string(file)
            puts "Metadata: #{key} = #{value}"

            # Return to previous position to check next byte
            file.seek(-1, IO::SEEK_CUR)
          end

          # Move forward one byte since we went back one too many
          file.seek(1, IO::SEEK_CUR)
        end
      end
    end
  end
end
