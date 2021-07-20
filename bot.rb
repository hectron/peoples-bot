require "logger"
require "discordrb"
require_relative "./app/constants"
require_relative "./app/discord/command"
require_relative "./app/vaccine_spotter/api"
require_relative "./app/vaccine_spotter/result"
require_relative "./app/beach_sand"

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::INFO

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_BOT_CLIENT_TOKEN"],
  client_id: ENV["DISCORD_BOT_CLIENT_ID"],
  prefix: BOT_COMMAND_PREFIX,
)

VACCINE_TYPES.each do |type|
  command_config = {
    help_available: true,
    description: "Find #{type} vaccines",
    usage: <<~USAGE.strip
      !#{type} <STATE> [<CITY> (optional)] <zipcode1> <zipcode2> ... <zipcodeN>

      Examples:
        !#{type} IL
        !#{type} IL Chicago
        !#{type} IL 60601 60613 60657
        !#{type} IL Chicago 60613 60660
    USAGE
  }

  bot.command(type.to_sym, command_config) do |_event, state, *args|
    LOGGER.info "Command type: #{type}, State: #{state}, Args: #{args.inspect}"

    command = Discord::Command.new(args)
    locations = VaccineSpotter::Api.find_in(
      state: state,
      vaccine_type: type,
      city: command.city,
      zipcodes: command.zipcodes,
    )

    VaccineSpotter::Result.display(locations).tap do |msg|
      LOGGER.info msg
    end
  end
end

bot.command(
  :beach,
  help_available: true,
  description: "Primes the sands for temporary messaging.",
  usage: "React to the first message the bot posted with :ocean: to cause a deluge",
) do |event|
  msg = event.respond "The waves subside. For a brief moment, you can write in sand before then next tide. When you are done, react to the bot message with :ocean:."
  done_emoji = "\u{1f30a}"

  msg.react(done_emoji)

  bot.add_await!(Discordrb::Events::ReactionAddEvent, emoji: done_emoji, timeout: 600, message: msg) do |reaction_event|
    deleter = BeachSand::MessageDeleter.new(message_id: msg.id, channel_id: msg.channel.id, api_token: bot.token)

    begin
      deleter.execute
    rescue NoMessagesError, ArgumentError => e
      LOGGER.error(e)
    end

    reaction_event.respond "The tides roll in, and the sand begins to smooth out."
  end
end

at_exit { bot.stop }
bot.run
