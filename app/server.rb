require 'socket'
require 'byebug'

Dir[File.join(__dir__, 'redis_ruby', '**', '*.rb')].sort.each { |file| require file }

def parse_arguments
  args = {}
  i = 0

  while i < ARGV.length
    case ARGV[i]
    when '--dir'
      args[:dir] = ARGV[i + 1]
      i += 2
    when '--dbfilename'
      args[:dbfilename] = ARGV[i + 1]
      i += 2
    else
      i += 1
    end
  end

  args
end

RedisRuby::Server.new(6379, parse_arguments).start
