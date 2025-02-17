module RedisRuby
  module RDB
    class Parser
      include Modules::BinaryUtils
      include Modules::MetadataReader
      include Modules::HeaderReader
      include Modules::DatabaseReader

      EOF_MARKER = 0xFF

      def initialize(rdb_file_path)
        @file = File.open(rdb_file_path, 'rb')
        @result = {}
        @metadata = {}
        @debug = true
      end

      def parse
        read_header(@file)
        read_data
        debug "Final result hash: #{@result.inspect}"
        @result
      ensure
        @file.close
      end

      private

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
            read_key_value_pairs
          else
            debug "Unexpected type: #{type}"
            # Retrocedemos un byte para que pueda ser leído como parte de un string
            @file.seek(-1, IO::SEEK_CUR)
            handle_key_value_pair(@file)
          end
        end
      end

      def read_key_value_pairs
        loop do
          type = @file.read(1)
          break if type.nil?

          type = type.unpack1('C')
          debug "Read type in key-value pairs: 0x#{type.to_s(16)}"
          break if type == EOF_MARKER

          case type
          when EXPIRETIME_MS
            debug 'Found expiry marker'
            expiry = handle_expiry(@file)
            handle_key_value_pair(@file, expiry)
          when TYPE_STRING
            debug 'Found string marker'
            handle_key_value_pair(@file)
          else
            debug 'Found string value'
            @file.seek(-1, IO::SEEK_CUR)
            handle_key_value_pair(@file)
          end
        end
      end

      def debug(message)
        puts message if @debug
      end
    end
  end
end
