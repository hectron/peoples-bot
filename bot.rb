require "discordrb"
require_relative "./constants"
require_relative "./discord_command"
require_relative "./vaccine_spotter_api"

bot = Discordrb::Commands::CommandBot.new(token: ENV["DISCORD_BOT_CLIENT_TOKEN"],
                                          client_id: ENV["DISCORD_BOT_CLIENT_ID"],
                                          prefix: COMMAND_PREFIX)

VACCINE_TYPES.each do |type|
  bot.command(
    type.to_sym,
    {
      help_available: true,
      description: "Find #{type} vaccines",
      usage: <<~USAGE.strip,
      #{type} <STATE> <zipcode1>, <zipcode2>, ...

      Examples:
        #{type} IL
        #{type} 60601, 60613, 60657
      USAGE
    })
  do |_event, arguments|
    command = DiscordCommand.parse(arguments)
    results = VaccineSpotterApi.find_for(command.state, vaccine_type: type, zipcodes: command.zipcodes)

    VaccineSpotterResult.display(results)
  end
end

at_exit { bot.stop }
bot.run
