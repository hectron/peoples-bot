require "ostruct"

# A smol class to allow for dynamic configuration
class Application < OpenStruct
  class << self
    def configure
      instance = new

      yield instance

      instance.each_pair do |attr, value|
        define_singleton_method attr do
          value
        end
      end
    end
  end
end

Application.configure do |config|
  # application metadata

  config.root = File.absolute_path(File.join(__dir__, "..", ".."))
  config.sha = ENV["HEROKU_SLUG_COMMIT"].to_s[0..7]
  config.version = ENV["HEROKU_RELEASE_VERSION"].to_s

  # Bot configuration
  config.bot_token = ENV["DISCORD_BOT_CLIENT_TOKEN"]
  config.bot_client_id = ENV["DISCORD_BOT_CLIENT_ID"]
  config.bot_prefix = "!".freeze
  config.bot_status = [].tap do |status|
    status << "type #{config.bot_prefix}help for help"
    status << config.version if config.version != ""
    status << "sha: #{config.sha}" if config.sha != ""
  end.join(" | ")

  # Beach configuration
  config.beach_session_timeout = ENV.fetch("BEACH_SESSION_TIMEOUT", 60 * 10).to_i
end
