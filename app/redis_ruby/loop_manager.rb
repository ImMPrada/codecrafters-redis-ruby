module RedisRuby
  class LoopManager
      attr_accessor :clients, :pending_reads, :server
  
    def initialize(server)
      @server = server
      @clients = {}
      @pending_reads = {}
    end
  
    def create_redeable_sockets
      readable_sockets, = IO.select([server] + clients.keys) # https://ruby-doc.org/core-2.7.5/IO.html
      readable_sockets
    end
  
    def accept_new_client
      client = server.accept
      clients[client] = true
      pending_reads[client] = ""
    rescue StandardError => e
      puts "Error accepting client: #{e.message}"
    end
  
    def remove_client(client)
      clients.delete(client)
      pending_reads.delete(client)
    end
  end
end
