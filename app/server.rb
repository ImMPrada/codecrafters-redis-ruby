require 'socket'
require 'byebug'
require_relative 'commands/ping'
require_relative 'commands_router'

class YourRedisServer
  def initialize(port)
    @port = port
    @commands_router = CommandsRouter.new
  end

  def start
    puts('Logs from your program will appear here!')
    server = TCPServer.new(port)

    loop do
      @client = server.accept
      handle_client
    end
  end

  def handle_client
    loop do
      command_array = read_resp_array
      break if command_array.nil?

      input = command_array.first.upcase
      command = commands_router.resolve_command(input, client)

      command.call
    rescue StandardError => e
      client.puts("-ERR #{e.message}\r\n")
    end

    client.close
  end

  def read_resp_array
    first_line = client.gets
    return nil if first_line.nil?

    return [first_line.strip] if first_line[0] != '*'

    array_length = first_line[1..-3].to_i
    array = []

    array_length.times do
      length_prefix = client.gets
      return nil if length_prefix.nil?

      length = length_prefix[1..-3].to_i
      value = client.gets.strip[0...length]

      array << value
    end

    array
  end

  private

  attr_reader :port, :client, :commands_router
end

YourRedisServer.new(6379).start
