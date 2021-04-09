require "spec_helper"
require_relative "../vaccine_spotter_command"

describe VaccineSpotterCommand do
  describe ".parse_arguments" do
    context "setting state" do
      it "parses states correctly" do
        got = VaccineSpotterCommand.parse("IL")
        expect(got.state).to eq("IL")
      end

      it "parses states regardless of casing" do
        got = VaccineSpotterCommand.parse("iL")
        expect(got.state).to eq("IL")
      end

      it "handles whitespace in state correctly" do
        got = VaccineSpotterCommand.parse("      IL       ")
        expect(got.state).to eq("IL")
      end

      it "returns the right state when handling both state and zipcodes" do
        got = VaccineSpotterCommand.parse("    IL   60601     60622  ")
        expect(got.state).to eq("IL")
      end

      it "raises an error if the state is not valid" do
        expect { VaccineSpotterCommand.parse("II") }.to raise_error(ArgumentError)
      end
    end

    context "setting zipcodes" do
      it "raises an exception if only zipcodes are passed" do
        expect { VaccineSpotterCommand.parse("60601 60622") }.to raise_error(ArgumentError)
      end

      it "handles zipcodes separated with whitespace correctly" do
        got = VaccineSpotterCommand.parse("IL 60601 60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "handles zipcodes separated with commas correctly" do
        got = VaccineSpotterCommand.parse("IL 60601, 60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "handles zipcodes separated with commas and whitespace correctly" do
        got = VaccineSpotterCommand.parse("IL 60601,60622")
        expect(got.zipcodes).to match_array(["60601", "60622"])
      end

      it "raises an error if the zipcodes are malformed" do
        expect { VaccineSpotterCommand.parse("IL 606") }.to raise_error(ArgumentError)
      end

      it "raises an error if the zipcode is not a zipcode" do
        expect { VaccineSpotterCommand.parse("IL 606s1") }.to raise_error(ArgumentError)
      end
    end
  end
end
