require "discordrb"

require_relative "./config/initializers"

bot = Discordrb::Commands::CommandBot.new(
  token: Application.bot_token,
  client_id: Application.bot_client_id,
  prefix: Application.bot_prefix,
)

bot.ready do |ready_event|
  bot.update_status("online", Application.bot_status, nil)
end

Vaccines::Types.each do |type|
  command_config = {
    help_available: true,
    description: "Find #{type} vaccines",
    usage: <<~USAGE.strip
      #{Application.bot_prefix}#{type} <zipcode>

    Examples:
      #{Application.bot_prefix}#{type} 60601
    USAGE
  }

  vaccine_guid = Vaccines::TypeToGuid[type]

  bot.command(type.to_sym, command_config) do |_event, postal_code|
    providers = Vaccines::Api.new(vaccine_guid).find_in(postal_code: postal_code)

    if providers.any?
      Vaccines::Result.display(providers.sort_by(&:distance).first(7))
    else
      "Did not find any appointments for #{postal_code}"
    end
  end
end

bot.command(
  :beach,
  help_available: true,
  description: "Primes the sands for temporary messaging.",
  usage: "React to the first message the bot posted with :ocean: to cause a deluge",
) do |event|
  session_name = event.channel.id

  unless BeachSand::SessionManager.acquire_lock(session_name, timeout: Application.beach_session_timeout)
    next "There is a current beach session in progress. This will be ignored until then."
  end

  msg = event.respond "The waves subside. For a brief moment, you can write in sand before then next tide. When you are done, react to the bot message with :ocean:."
  done_emoji = "\u{1f30a}"

  msg.react(done_emoji)

  bot.add_await!(Discordrb::Events::ReactionAddEvent, emoji: done_emoji, timeout: Application.beach_session_timeout, message: msg) do |reaction_event|
    # Since this code will run on every :ocean: reaction, it might not
    # be on our time message we sent earlier. We use `next` to skip the rest
    # of the block unless it was our message that was reacted to.
    next true unless reaction_event.message.id == msg.id

    deleter = BeachSand::MessageDeleter.new(message_id: msg.id, channel_id: msg.channel.id, api_token: bot.token)

    begin
      msg.delete
      deleter.execute
    rescue BeachSand::MessageDeleter::NoMessagesError, ArgumentError => e
      BobLog.error(e)
    end

    BeachSand::SessionManager.release_lock(session_name)

    reaction_event.respond "The tides roll in, and the sand begins to smooth out."
  end

  BeachSand::SessionManager.release_lock(session_name)

  nil
end

bot.command(:gh, help_available: true, description: "Returns a url to view the latest code release") do |_event|
  if Application.sha
    "https://github.com/hectron/peoples-bot/commit/#{Application.sha}"
  else
    "Could not determine current SHA."
  end
end

at_exit { bot.stop }
bot.run
