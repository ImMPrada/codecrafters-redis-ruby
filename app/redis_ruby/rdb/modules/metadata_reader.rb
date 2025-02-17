module RedisRuby
  module RDB
    module Modules
      module MetadataReader
        TYPE_METADATA = 0x04

        def handle_metadata(file)
          key = read_string(file)
          value = read_string(file)
          @metadata[key] = value
        end
      end
    end
  end
end
