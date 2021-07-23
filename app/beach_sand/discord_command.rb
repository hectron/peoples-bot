require "set"

module BeachSand
  class DiscordCommand < ::DiscordCommand
    ActiveSessions = Set.new([])
    DoneEmoji = "\u{1f30a}".freeze

    name :beach
    description "Primes the sands for temporary messaging.".freeze
    usage "React to the bot's original message with :ocean: to cause a deluge.".freeze

    event_handler ->(event) do
      unless ActiveSessions.add?(event.channel.id)
        return "There is a current beach session in progress. This will be ignored until then."
      end

      msg = event.respond "The waves subside. For a brief moment, you can write in sand before then next tide. When you are done, react to the bot message with :ocean:."

      msg.react(DoneEmoji)

      @bot.add_await!(Discordrb::Events::ReactionAddEvent, emoji: DoneEmoji, timeout: 600, message: msg) do |reaction_event|
        # Since this code will run on every :ocean: reaction, it might not
        # be on our time message we sent earlier. We use `next` to skip the rest
        # of the block unless it was our message that was reacted to.
        next true unless reaction_event.message.id == msg.id

        deleter = BeachSand::MessageDeleter.new(message_id: msg.id, channel_id: msg.channel.id, api_token: @bot.token)

        begin
          msg.delete
          deleter.execute
        rescue BeachSand::MessageDeleter::NoMessagesError, ArgumentError => e
          BobLog.error(e)
        end

        ActiveSessions.delete?(msg.channel.id)

        reaction_event.respond "The tides roll in, and the sand begins to smooth out."
      end

      ActiveSessions.delete?(msg.channel.id)

      nil
    end
  end
end
