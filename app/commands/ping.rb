require_relative 'base'

module Commands
  class Ping < Base
    def call
      client.puts(resp_encoder('+PONG'))
    end
  end
end
