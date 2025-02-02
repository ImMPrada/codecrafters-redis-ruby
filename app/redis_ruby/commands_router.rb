module RedisRuby
  class CommandsRouter
    COMMANDS = {
      'PING' => Commands::Ping,
      'ECHO' => Commands::Echo,
      'SET' => Commands::Set,
      'GET' => Commands::Get
    }.freeze

    def resolve_command(input, client, data_store)
      command = COMMANDS[input]
      raise "Unknown command: #{input}" if command.nil?

      command.new(client, data_store)
    end
  end
end
