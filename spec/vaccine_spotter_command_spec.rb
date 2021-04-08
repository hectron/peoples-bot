require "spec_helper"
require_relative "../vaccine_spotter_command"

describe VaccineSpotterCommand do
  describe ".parse_arguments" do
    [
      { description: "parses only state correctly", attribute: :state, want: "IL", arguments: "IL" },
      { description: "handles whitespace in state correctly", attribute: :state, want: "IL", arguments: "      IL       " },
      { description: "handles zipcodes separated with whitespace correctly", attribute: :zipcodes, want: ["60601", "60622"], arguments: "60601 60622" },
      { description: "handles zipcodes separated with commas correctly", attribute: :zipcodes, want: ["60601", "60622"], arguments: "60601,60622" },
      { description: "handles zipcodes separated with commas and whitespace correctly", attribute: :zipcodes, want: ["60601", "60622"], arguments: "60601, 60622" },
      { description: "handles state and zipcodes", attribute::tabe

    ].each_with_index do |test_case, i|
      it "#{test_case[:description]} using #{test_case[:arguments]}" do
        got = VaccineSpotterCommand.parse(test_case[:arguments])

        expect(got.send(test_case[:attribute])).to eq(test_case[:want])
      end
    end
  end
end
