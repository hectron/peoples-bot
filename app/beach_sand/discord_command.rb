require "set"

module BeachSand
  class DiscordCommand
    @@active_sessions = Set.new([])

    DoneEmoji = "\u{1f30a}".freeze

    def initialize(bot)
      @bot = bot
    end

    def register
      @bot.command(self.class.name,
                   self.class.description,
                   help_available: true,
                   self.class.config) do |event|
        handle(event)
      end
    end

    def handle(event)
      unless @@active_sessions.add?(event.channel.id)
        next "There is a current beach session in progress. This will be ignored until then."
      end

      msg = event.respond "The waves subside. For a brief moment, you can write in sand before then next tide. When you are done, react to the bot message with :ocean:."
      done_emoji = "\u{1f30a}"

      msg.react(DoneEmoji)

      bot.add_await!(Discordrb::Events::ReactionAddEvent, emoji: DoneEmoji, timeout: 600, message: msg) do |reaction_event|
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

        @@active_sessions.delete?(msg.channel.id)

        reaction_event.respond "The tides roll in, and the sand begins to smooth out."
      end

      nil
    end

    class << self
      def name
        :beach
      end

      def description
        "Primes the sands for temporary messaging.".freeze
      end

      def usage
        "React to the bot's original message with :ocean: to cause a deluge.".freeze
      end

      def config
        {}.tap do |conf|
          conf[:description] = description
          conf[:usage] = usage
        end
      end

    end
  end
end
