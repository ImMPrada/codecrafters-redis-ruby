require_relative 'commands/ping'

class CommandsRouter
  COMMANDS = {
    'PING' => Commands::Ping
  }.freeze

  def resolve_command(input, client)
    command = COMMANDS[input]
    raise "Unknown command: #{input}" if command.nil?

    command.new(client)
  end
end
