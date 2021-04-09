require "discordrb"
require_relative "./constants"
require_relative "./vaccine_spotter_api"
require_relative "./vaccine_spotter_command"

bot = Discordrb::Commands::CommandBot.new(token: ENV["DISCORD_BOT_CLIENT_TOKEN"],
                                          client_id: ENV["DISCORD_BOT_CLIENT_ID"],
                                          prefix: COMMAND_PREFIX)

VACCINE_TYPES.each do |type|
  bot.command type.to_sym do |_event, arguments|
    command = VaccineSpotterCommand.parse(arguments)

    results = VaccineSpotterApi.find_for(command.state,
                                         vaccine_type: command.vaccine_type,
                                         zipcodes: command.zipcodes)

    VaccineSpotterResult.display(results)
  end
end

at_exit { bot.stop }
bot.run
