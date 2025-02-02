module RedisRuby
  class Server
    def initialize(port)
      @port = port
      @commands_router = CommandsRouter.new
    end
  
    def start
      puts('Logs from your program will appear here!')
      @server = TCPServer.new(@port)
      @loop_manager = LoopManager.new(server)
      
      # Main loop
      loop do
        readable_sockets = loop_manager.create_redeable_sockets
  
        readable_sockets.each do |socket|
          if socket == server
            loop_manager.accept_new_client
            next
          end
  
          handle_client_data(socket)
        end
      end
    end
  
    private
  
    attr_accessor :port, :commands_router, :server, :loop_manager
  
    def handle_client_data(client)
      command_array = read_resp_array(client)
      
      if command_array.nil?
        cleanup_client(client)
        return
      end
  
      input = command_array.first.upcase
      command = commands_router.resolve_command(input, client)
      command.call
    rescue StandardError => e
      client.puts("-ERR #{e.message}\r\n")
      cleanup_client(client)
    end
  
    def cleanup_client(client)
      client.close
      loop_manager.remove_client(client)
    end
  
    # RESP Redis Serialization Protocol
    # https://redis.io/docs/latest/protocol/
  
    def read_resp_array(client)
      first_line = client.gets # indicates the number of elements in the array *1\r\n 1 element array
      return nil if first_line.nil?
      return [first_line.strip] if first_line[0] != '*'
  
      array_length = first_line[1..-3].to_i # extracts the number of elements in the array
      array = []
  
      array_length.times do
        length_prefix = client.gets # indicates the length of the value $4\r\n an element of size 4
        return nil if length_prefix.nil?
  
        length = length_prefix[1..-3].to_i # extracts the length of the value
        value = client.gets.strip[0...length] # extracts the value, beacuse here cient.gets returns PING\r\n for example
  
        array << value
      end
  
      array
    end
  end
end
