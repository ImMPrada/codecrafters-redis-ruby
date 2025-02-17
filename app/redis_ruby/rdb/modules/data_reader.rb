module RedisRuby
  module RDB
    module Modules
      module DataReader
        def read_data
          loop do
            type = @file.read(1)
            break if type.nil?

            type = type.unpack1('C')
            debug "Read type: 0x#{type.to_s(16)}"
            break if type == EOF_MARKER

            case type
            when TYPE_METADATA
              debug 'Handling metadata'
              handle_metadata(@file)
            when SELECT_DB
              debug 'Handling database selection'
              handle_database(@file)
              read_key_value_pairs(@file)
            else
              debug "Unexpected type: #{type}"
              @file.seek(-1, IO::SEEK_CUR)
              handle_key_value_pair(@file)
            end
          end
        end

        private

        def read_next_entry(file)
          type = file.read(1)
          return if type.nil?

          type = type.unpack1('C')
          debug "Read next type: 0x#{type.to_s(16)}"

          case type
          when EXPIRETIME_MS
            debug 'Found expiry marker'
            expiry = handle_expiry(file)
            handle_key_value_pair(file, expiry)
          when TYPE_STRING
            debug 'Found string marker'
            file.seek(-1, IO::SEEK_CUR)
            handle_key_value_pair(file)
          when EOF_MARKER
            debug 'Found EOF marker'
          else
            debug "Skipping unknown type: #{type}"
          end
        end
      end
    end
  end
end
