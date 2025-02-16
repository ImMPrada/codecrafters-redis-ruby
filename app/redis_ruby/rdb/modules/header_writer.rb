module RedisRuby
  module RDB
    module Modules
      module HeaderWriter
        def write_header
          @file.write(MAGIC_HEADER)
        end
      end
    end
  end
end
