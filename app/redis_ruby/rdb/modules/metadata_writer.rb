module RedisRuby
  module RDB
    module Modules
      module MetadataWriter
        def write_metadata(key, value)
          @file.write([0xFA].pack('C')) # FA indicates start of metadata
          write_string(key)
          write_string(value)
        end
      end
    end
  end
end
