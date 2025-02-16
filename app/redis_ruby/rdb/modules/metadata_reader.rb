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
          end
        end
      end
    end
  end
end
