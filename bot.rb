require "discordrb"

require_relative "./config/initializers"

bot = Discordrb::Commands::CommandBot.new(
  token: Application.bot_token,
  client_id: Application.bot_client_id,
  prefix: Application.bot_prefix,
)

bot.ready do |_ready_event|
  bot.update_status("online", Application.bot_status, nil)
end

VACCINE_TYPES.each do |type|
  command_config = {
    help_available: true,
    description: "Find #{type} vaccines",
    usage: <<~USAGE.strip
      #{Application.bot_prefix}#{type} <STATE> [<CITY> (optional)] <zipcode1> <zipcode2> ... <zipcodeN>

      Examples:
        #{Application.bot_prefix}#{type} IL
        #{Application.bot_prefix}#{type} IL Chicago
        #{Application.bot_prefix}#{type} IL 60601 60613 60657
        #{Application.bot_prefix}#{type} IL Chicago 60613 60660
    USAGE
  }

  bot.command(type.to_sym, command_config) do |_event, state, *args|
    BobLog.info "Command type: #{type}, State: #{state}, Args: #{args.inspect}"

    command = Discord::Command.new(args)
    locations = VaccineSpotter::Api.find_in(
      state: state,
      vaccine_type: type,
      city: command.city,
      zipcodes: command.zipcodes,
    )

    VaccineSpotter::Result.display(locations).tap do |msg|
      BobLog.info msg
    end
  end
end

commands = [
  VaccineSpotter::DiscordCommand.all,
  BeachSand::DiscordCommand,
].flatten

commands.each do |discord_command|
  discord_command.new(bot).register
end

at_exit { bot.stop }
bot.run
