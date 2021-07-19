require "date"
require "time"

module BeachSand
  module Structs
    # 60 seconds, for 60 minutes, 24 times a day, 7 days in a week, for two weeks
    TwoWeeksAgo = 60 * 60 * 24 * 7 * 2

    DiscordMessage = Struct.new(:id, :author_id, :timestamp, keyword_init: true) do
      # @return [Array[DiscordMessage]]
      def self.from_api_response(response)
        response.map do |msg|
          new(
            id: msg["id"],
            author_id: msg.dig("author", "id"),
            timestamp: DateTime.parse(msg["timestamp"]),
          )
        end
      end

      def deletable?
        timestamp.to_time.to_i > (Time.now.to_i - TwoWeeksAgo)
      end

      def between_time?(start_time, end_time)
        message_time = timestamp.to_time.to_i 

        message_time >= start_time.to_i && message_time <= end_time.to_i
      end
    end
  end
end
