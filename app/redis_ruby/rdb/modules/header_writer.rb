module RedisRuby
  module RDB
    module Modules
      module HeaderWriter
        MAGIC_HEADER = 'REDIS0011'.freeze

        def write_header
          @file.write(MAGIC_HEADER)
        end
      end
    end
  end
end
