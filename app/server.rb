require 'socket'
require 'byebug'

Dir[File.join(__dir__, 'redis_ruby', '**', '*.rb')].sort.each { |file| require file }

RedisRuby::Server.new(6379).start
