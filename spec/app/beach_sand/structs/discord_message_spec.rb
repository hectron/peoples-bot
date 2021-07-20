require "spec_helper"

describe BeachSand::Structs::DiscordMessage do
  describe ".from_api_response" do
    let(:response) {
      [
        {
          "id" => "1",
          "author" => { "id" => "1" },
          "timestamp" => "2021-01-01",
        },
        {
          "id" => "2",
          "author" => { "id" => "1" },
          "timestamp" => "2021-01-01",
        }
      ]
    }

    it "returns an array of messages" do
      results = BeachSand::Structs::DiscordMessage.from_api_response(response)
      expect(results).to all(be_a(BeachSand::Structs::DiscordMessage))

      expect(results.size).to eq(2)

      expect(results.first).to have_attributes(id: "1", author_id: "1")
      expect(results.last).to have_attributes(id: "2", author_id: "1")
    end
  end

  describe "#deletable?" do
    context "when the message is older than a few weeks ago" do
      it "is false" do
        instance = BeachSand::Structs::DiscordMessage.new(id: 1, author_id: 1, timestamp: Time.at(Time.now - (BeachSand::Structs::TwoWeeksAgo + 10)))

        expect(instance.deletable?).to be_falsey
      end
    end

    context "when the message is within the last two weeks" do
      it "is true" do
        instance = BeachSand::Structs::DiscordMessage.new(id: 1, author_id: 1, timestamp: Time.now)

        expect(instance.deletable?).to be_truthy
      end
    end
  end
end
