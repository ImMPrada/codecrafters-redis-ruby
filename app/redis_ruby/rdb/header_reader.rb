module RedisRuby
  module RDB
    module HeaderReader
      def read_header(file)
        header = file.read(9)
        raise 'Invalid format' unless header.start_with?('REDIS')

        puts "RDB Version: #{header[5..]}"
      end
    end
  end
end
