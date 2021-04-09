require "spec_helper"
require_relative "../discord_command"

describe DiscordCommand do
  describe ".parse_arguments" do
    context "setting state" do
      it "parses states correctly" do
        got = described_class.parse("IL")
        expect(got.state).to eq("IL")
      end

      it "parses states regardless of casing" do
        got = described_class.parse("iL")
        expect(got.state).to eq("IL")
      end

      it "handles whitespace in state correctly" do
        got = described_class.parse("      IL       ")
        expect(got.state).to eq("IL")
      end

      it "returns the right state when handling both state and zipcodes" do
        got = described_class.parse("    IL   60601     60622  ")
        expect(got.state).to eq("IL")
      end

      it "raises an error if the state is not valid" do
        expect { described_class.parse("II") }.to raise_error(ArgumentError)
      end
    end

    context "setting zipcodes" do
      it "raises an exception if only zipcodes are passed" do
        expect { described_class.parse("60601 60622") }.to raise_error(ArgumentError)
      end

      it "handles zipcodes separated with whitespace correctly" do
        got = described_class.parse("IL 60601 60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "handles zipcodes separated with commas correctly" do
        got = described_class.parse("IL 60601, 60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "handles zipcodes separated with commas and whitespace correctly" do
        got = described_class.parse("IL 60601,60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "raises an error if the zipcodes are malformed" do
        expect { described_class.parse("IL 606") }.to raise_error(ArgumentError)
      end

      it "raises an error if the zipcode is not a zipcode" do
        expect { described_class.parse("IL 606s1") }.to raise_error(ArgumentError)
      end
    end
  end
end
