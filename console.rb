require "discordrb"
require "pry"
require "./config/initializers"

bot = Discordrb::Commands::CommandBot.new(token: Application.bot_token, client_id: Application.bot_client_id, prefix: Application.bot_prefix)

binding.pry

bot.run :async

binding.pry
