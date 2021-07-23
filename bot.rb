require "logger"
require "discordrb"
require_relative "./app/constants"
require_relative "./app/discord/command"
require_relative "./app/vaccine_spotter/api"
require_relative "./app/vaccine_spotter/result"
require_relative "./app/beach_sand"

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::INFO
Sha = ENV.fetch("HEROKU_SLUG_COMMIT", "")[0..7]

bot = Discordrb::Commands::CommandBot.new(
  token: ENV["DISCORD_BOT_CLIENT_TOKEN"],
  client_id: ENV["DISCORD_BOT_CLIENT_ID"],
  prefix: BOT_COMMAND_PREFIX,
)

bot.ready do |ready_event|
  status = "#{BOT_COMMAND_PREFIX} help"
  status += "| version: #{Sha}" if Sha

  bot.update_status("online", status, nil)
end

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

ChannelIdsWithActiveBeaches = Set.new([])

bot.command(
  :beach,
  help_available: true,
  description: "Primes the sands for temporary messaging.",
  usage: "React to the first message the bot posted with :ocean: to cause a deluge",
) do |event|
  unless ChannelIdsWithActiveBeaches.add?(event.channel.id)
    next "There is a current beach session in progress. This will be ignored until then."
  end

  msg = event.respond "The waves subside. For a brief moment, you can write in sand before then next tide. When you are done, react to the bot message with :ocean:."
  done_emoji = "\u{1f30a}"

  msg.react(done_emoji)

  bot.add_await!(Discordrb::Events::ReactionAddEvent, emoji: done_emoji, timeout: 600, message: msg) do |reaction_event|
    # Since this code will run on every :ocean: reaction, it might not
    # be on our time message we sent earlier. We use `next` to skip the rest
    # of the block unless it was our message that was reacted to.
    next true unless reaction_event.message.id == msg.id

    deleter = BeachSand::MessageDeleter.new(message_id: msg.id, channel_id: msg.channel.id, api_token: bot.token)

    begin
      msg.delete
      deleter.execute
    rescue BeachSand::MessageDeleter::NoMessagesError, ArgumentError => e
      LOGGER.error(e)
    end

    ChannelIdsWithActiveBeaches.delete?(msg.channel.id)

    reaction_event.respond "The tides roll in, and the sand begins to smooth out."
  end

  nil
end

at_exit { bot.stop }
bot.run
