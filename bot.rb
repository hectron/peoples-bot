require "logger"
require "discordrb"
require_relative "./constants"
require_relative "./discord_command"
require_relative "./vaccine_spotter_api"
require_relative "./vaccine_spotter_result"

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

bot = Discordrb::Commands::CommandBot.new(token: ENV["DISCORD_BOT_CLIENT_TOKEN"],
                                          client_id: ENV["DISCORD_BOT_CLIENT_ID"],
                                          prefix: BOT_COMMAND_PREFIX)

VACCINE_TYPES.each do |type|
  command_config = {
    help_available: true,
    description: "Find #{type} vaccines",
    usage: <<~USAGE.strip,
      #{type} <STATE> <zipcode1> <zipcode2> ... <zipcodeN>

      Examples:
        #{type} IL
        #{type} 60601 60613 60657
    USAGE
  }

  bot.command(type.to_sym, command_config) do |_event, state, *args|
    LOGGER.info <<~INFO
      Command type: #{type}, State: #{state}, Args: #{args}
      Event: #{_event}
    INFO

    command = DiscordCommand.new(args)
    locations = VaccineSpotterApi.find_in(state: state,
                                          vaccine_type: type,
                                          city: command.city,
                                          zipcodes: command.zipcodes)

    VaccineSpotterResult.display(locations).tap do |msg|
      LOGGER.info msg
    end
  end
end

at_exit { bot.stop }
bot.run
