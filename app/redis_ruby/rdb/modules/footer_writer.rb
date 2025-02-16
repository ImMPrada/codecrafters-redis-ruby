module RedisRuby
  module RDB
    module Modules
      module FooterWriter
        def write_footer
          @file.write([EOF_MARKER].pack('C')) # FF marks the end of file
          @file.write([0x00] * 8) # Dummy checksum (8 bytes of zeros)
        end
      end
    end
  end
end
