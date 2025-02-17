module RedisRuby
  module RDB
    module Modules
      module DatabaseOperationsReader
        # Special Opcodes
        SELECT_DB = 0xFE
        EXPIRETIME_MS = 0xFC
        EOF_MARKER = 0xFF

        def handle_database(file)
          db_number = file.read(1)
          return if db_number.nil?

          db_number = db_number.unpack1('C')
          debug "Selected DB: #{db_number}"
        end

        def handle_expiry(file)
          expiry = file.read(8)
          return if expiry.nil?

          expiry = expiry.unpack1('Q>')
          debug "Expiry: #{expiry}"
          expiry
        end

        def read_key_value_pairs(file)
          loop do
            type = file.read(1)
            break if type.nil?

            type = type.unpack1('C')
            debug "Read type in key-value pairs: 0x#{type.to_s(16)}"
            break if type == EOF_MARKER

            case type
            when EXPIRETIME_MS
              debug 'Found expiry marker'
              expiry = handle_expiry(file)
              handle_key_value_pair(file, expiry)
            when TYPE_STRING
              debug 'Found string marker'
              handle_key_value_pair(file)
            else
              debug 'Found string value'
              file.seek(-1, IO::SEEK_CUR)
              handle_key_value_pair(file)
            end
          end
        end
      end
    end
  end
end
