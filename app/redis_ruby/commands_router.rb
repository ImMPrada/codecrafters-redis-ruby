module RedisRuby
  class CommandsRouter
    COMMANDS = {
      'PING' => Commands::Ping,
      'ECHO' => Commands::Echo
    }.freeze

    def resolve_command(input, client)
      command = COMMANDS[input]
      raise "Unknown command: #{input}" if command.nil?

      command.new(client)
    end
  end
end
