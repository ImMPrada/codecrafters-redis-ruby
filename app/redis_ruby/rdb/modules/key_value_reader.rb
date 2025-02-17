module RedisRuby
  module RDB
    module Modules
      module KeyValueReader
        # Value Types
        TYPE_STRING = 0x00

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
      end
    end
  end
end
