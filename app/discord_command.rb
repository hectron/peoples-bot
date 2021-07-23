class DiscordCommand
  def initialize(bot)
    @bot = bot
  end

  def register
    @bot.command(self.class.name, self.class.description, self.class.config) do |*args|
      self.class.event_handler.call(args)
    end
  end

  def self.event_handler(handler = nil)
    @@event_handler ||= handler
  end

  def self.name(name = nil)
    @@name ||= name
  end

  def self.description(description = nil)
    @@description ||= description
  end

  def self.usage(usage = nil)
    @@usage ||= usage
  end

  def self.help_available
    !!(usage || description)
  end

  def self.config
    {}.tap do |conf|
      conf[:description] = description if description
      conf[:usage] = usage if usage
      conf[:help_available] = help_available
    end
  end
end
