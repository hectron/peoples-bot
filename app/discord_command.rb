# Creates a shell that allows us to create a DSL
module AbstractDiscordCommand
  def included
    @event_handler = nil
    @name = nil
    @description = nil
    @usage = nil
    @help_available = false
  end

  def event_handler(handler = nil)
    @event_handler ||= handler
  end

  def name(name = nil)
    @name ||= name
  end

  def description(description = nil)
    @description ||= description
  end

  def usage(usage = nil)
    @usage ||= usage
  end

  def help_available
    !!(usage || description)
  end

  def config
    {}.tap do |conf|
      conf[:description] = description if description
      conf[:usage] = usage if usage
      conf[:help_available] = help_available
    end
  end
end

class DiscordCommand
  extend AbstractDiscordCommand

  def initialize(bot)
    @bot = bot
  end

  def register
    @bot.command(self.class.name, self.class.description, self.class.config) do |*args|
      self.class.event_handler.call(args)
    end
  end
end
