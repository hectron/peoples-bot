require "json"

module BeachSand
  class MessageDeleter
    DeleteReason = "The tides of time silence the qualms of life".freeze
    MaxNumberOfMessages = 100

    class NoMessagesError < StandardError; end

    # @param [Number] message_id
    # @param [Number] channel_id
    # @param [String] api_token
    def initialize(message_id:, channel_id:, api_token:)
      @message_id = message_id
      @channel_id = channel_id
      @api_token = api_token
    end

    def execute
      raise ArgumentError, "Need a message id" unless @message_id

      messages = fetch_messages

      unless messages.any?
        raise NoMessagesError, "Could not find any messages in channel: #{@channel_id} after message id: #{@message_id}"
      end

      delete_messages(messages)
    end

    private

    def fetch_messages
      all_messages = []

      max_id = @message_id

      loop do
        # only of before/after/around can be used at a given time
        #
        # @see https://discord.com/developers/docs/resources/channel#get-channel-messages
        api_response = Discordrb::API::Channel.messages(
          @api_token,
          @channel_id,
          MaxNumberOfMessages, # amount of messages (max 100)
          nil, # messages before this id
          max_id, # messages after this id
          nil, # messages around this id
        )

        break unless api_response.code == 200

        messages = BeachSand::Structs::DiscordMessage
          .from_api_response(JSON.parse(api_response.to_s))
          .select(&:deletable?)

        break unless messages.any?

        new_max_id = messages.map(&:id).max

        all_messages += messages

        break if new_max_id == max_id
        max_id = new_max_id
      end

      all_messages
    end

    def delete_messages(messages)
      messages.each_slice(MaxNumberOfMessages) do |message_slice|
        # LOGGER.info "Deleting messages: #{message_slice.size}"
        # LOGGER.info "Message ID: #{message_slice.map(&:id)}"

        Discordrb::API::Channel.bulk_delete_messages(
          @api_token,
          @channel_id,
          message_slice.map(&:id),
          DeleteReason,
        )
      end
    end
  end
end
