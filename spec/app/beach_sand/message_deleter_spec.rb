require "spec_helper"
require "discordrb"

describe BeachSand::MessageDeleter do
  describe "#execute" do
    before do
      allow(Discordrb::API::Channel).to receive(:messages)
      allow(Discordrb::API::Channel).to receive(:bulk_delete_messages)
    end

    context "when a message id is not provided" do
      it "does not run" do
        instance = BeachSand::MessageDeleter.new(message_id: nil, channel_id: 1, api_token: "test")

        expect { instance.execute }.to raise_error(ArgumentError, "Need a message id")
      end
    end

    context "when no messages are returned from discord" do
      it "raises an error" do
        mock_channel_id = 1
        mock_token = "test"
        mock_message_id = 1

        mock_api_response = double(code: 204)

        allow(Discordrb::API::Channel).to receive(:messages).with(
          mock_token,
          mock_channel_id,
          BeachSand::MessageDeleter::MaxNumberOfMessages,
          nil,
          mock_message_id,
          nil
        ).and_return(mock_api_response)

        instance = BeachSand::MessageDeleter.new(
          message_id: mock_message_id,
          channel_id: mock_channel_id,
          api_token: mock_token,
        )

        expect { instance.execute }.to raise_error(BeachSand::MessageDeleter::NoMessagesError)
      end
    end

    context "when messages are returned from discord" do
      it "deletes them" do
        mock_channel_id = 1
        mock_token = "test"
        mock_message_id = 1
        mock_response = [
          {
            id: 1,
            author: { id: 1 },
            timestamp: Time.now.to_s,
          }
        ]


        mock_api_response = double(code: 200, to_s: JSON.dump(mock_response))

        allow(Discordrb::API::Channel).to receive(:messages).with(
          mock_token,
          mock_channel_id,
          BeachSand::MessageDeleter::MaxNumberOfMessages,
          nil,
          mock_message_id,
          nil
        ).and_return(mock_api_response)

        instance = BeachSand::MessageDeleter.new(
          message_id: mock_message_id,
          channel_id: mock_channel_id,
          api_token: mock_token,
        )

        instance.execute

        expect(Discordrb::API::Channel).to have_received(:bulk_delete_messages).exactly(1).time

        expect(Discordrb::API::Channel).to have_received(:bulk_delete_messages).with(
          mock_token,
          mock_channel_id,
          [1],
          BeachSand::MessageDeleter::DeleteReason,
        )
      end

      it "paginates results and deletes them in batches" do
        mock_channel_id = 1
        mock_token = "test"
        mock_message_id = 1
        mock_response = 120.times.map do |i|
          {
            id: i + 1,
            author: { id: i + 1 },
            timestamp: Time.now.to_s,
          }
        end


        mock_api_response = double(code: 200, to_s: JSON.dump(mock_response.first(100)))
        mock_api_response2 = double(code: 200, to_s: JSON.dump(mock_response.last(20)))
        mock_api_response3 = double(code: 200, to_s: JSON.dump([]))

        allow(Discordrb::API::Channel).to receive(:messages).with(
          mock_token,
          mock_channel_id,
          BeachSand::MessageDeleter::MaxNumberOfMessages,
          nil,
          mock_message_id,
          nil
        ).and_return(mock_api_response)

        allow(Discordrb::API::Channel).to receive(:messages).with(
          mock_token,
          mock_channel_id,
          BeachSand::MessageDeleter::MaxNumberOfMessages,
          nil,
          100, # the next max id
          nil
        ).and_return(mock_api_response2)

        allow(Discordrb::API::Channel).to receive(:messages).with(
          mock_token,
          mock_channel_id,
          BeachSand::MessageDeleter::MaxNumberOfMessages,
          nil,
          120, # the next max id
          nil
        ).and_return(mock_api_response3)

        instance = BeachSand::MessageDeleter.new(
          message_id: mock_message_id,
          channel_id: mock_channel_id,
          api_token: mock_token,
        )

        instance.execute

        expect(Discordrb::API::Channel).to have_received(:bulk_delete_messages).exactly(2).times

        expect(Discordrb::API::Channel).to have_received(:bulk_delete_messages).with(
          mock_token,
          mock_channel_id,
          (1..100).map(&:to_i),
          BeachSand::MessageDeleter::DeleteReason,
        )

        expect(Discordrb::API::Channel).to have_received(:bulk_delete_messages).with(
          mock_token,
          mock_channel_id,
          (101..120).map(&:to_i),
          BeachSand::MessageDeleter::DeleteReason,
        )
      end
    end
  end
end
