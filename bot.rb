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

commands = [
  VaccineSpotter::DiscordCommand.all,
  BeachSand::DiscordCommand,
].flatten

commands.each do |discord_command|
  discord_command.new(bot).register
end

at_exit { bot.stop }
bot.run
