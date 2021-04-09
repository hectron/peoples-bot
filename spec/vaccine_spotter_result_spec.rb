require_relative "../vaccine_spotter_api"
require_relative "../vaccine_spotter_result"

describe VaccineSpotterResult do
  describe ".display" do
    context "when no locations are available" do
      it "says there are no appointments available" do
        expect(described_class.display([])).to eq("Did not find any appointments.")
      end
    end

    context "when there are locations available" do
      let(:locations) {
        [
          Location.new(name: "Taco",
                       provider: "Walmart",
                       url: "https://test-walmart.com",
                       city: "Chicago",
                       state: "IL",
                       postal_code: "60601",
                       appointments: [
                         Appointment.new(vaccine_types: ["jj"])
                       ]),
          Location.new(name: "Bell",
                       provider: "CVS",
                       url: "https://cvs-test.com",
                       city: "Chicago",
                       state: "IL",
                       postal_code: "60613",
                       appointments: [
                         Appointment.new(vaccine_types: ["jj", "pfizer"]),
                         Appointment.new(vaccine_types: ["jj", "moderna"]),
                       ]),
        ]
      }

      it "provides a summary of available appointments" do
        expect(described_class.display(locations)).to eq(<<~MSG.strip)
        Found 1 appointment(s) for the jj vaccine at Taco (Walmart) - Chicago, IL 60601

        Appointment URL: https://test-walmart.com

        Found 2 appointment(s) for the jj and pfizer and moderna vaccine at Bell (CVS) - Chicago, IL 60613

        Appointment URL: https://cvs-test.com
        MSG
      end
    end
  end
end