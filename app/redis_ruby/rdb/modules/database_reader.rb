require_relative 'string_value_reader'
require_relative 'key_value_reader'
require_relative 'database_operations_reader'
require_relative 'data_reader'

module RedisRuby
  module RDB
    module Modules
      module DatabaseReader # rubocop:disable Metrics/ModuleLength
        include StringValueReader
        include KeyValueReader
        include DatabaseOperationsReader
        include DataReader
        include BinaryUtils

        # Value Types
        TYPE_STRING = 0x00
        TYPE_METADATA = 0x04

        # String Encodings
        ENCODING_INT8 = 0x00
        ENCODING_INT16 = 0x01
        ENCODING_INT32 = 0x02

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

        def handle_key_value_pair(file, expiry = nil)
          debug 'Starting to read key-value pair'
          key = read_string(file)
          return if key.nil? || key.empty?

          debug "Read key: #{key.inspect}"

          value_type = file.read(1)
          return if value_type.nil?

          value_type = value_type.unpack1('C')
          debug "Value type: #{value_type}"

          case value_type
          when TYPE_STRING
            value = handle_string_value(file)
            if value
              result = expiry ? { value: value, xp: expiry } : { value: value }
              @result[key] = result
              debug "Stored key-value pair: #{key.inspect} => #{result.inspect}"
              debug "Current result hash: #{@result.inspect}"
            end
          else
            debug "Unsupported value type: #{value_type}"
          end
        end

        def handle_string_value(file) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
          encoding = file.read(1)
          return if encoding.nil?

          encoding = encoding.unpack1('C')
          debug "String encoding: #{encoding}"

          case encoding
          when ENCODING_INT8
            value = file.read(1)
            return if value.nil?

            value.unpack1('c').to_s
          when ENCODING_INT16
            value = file.read(2)
            return if value.nil?

            value.unpack1('s>').to_s
          when ENCODING_INT32
            value = file.read(4)
            return if value.nil?

            value.unpack1('l>').to_s
          else
            file.seek(-1, IO::SEEK_CUR)
            read_string(file)
          end
        end

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
