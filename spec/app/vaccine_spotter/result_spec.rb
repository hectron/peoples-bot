describe VaccineSpotter::Result do
  describe ".display" do
    context "when no locations are available" do
      it "says there are no appointments available" do
        expect(described_class.display([])).to eq("Did not find any appointments.")
      end
    end

    context "when there are locations available" do
      let(:locations) {
        [
          VaccineSpotter::Structs::Location.new(
            name: "Taco",
            provider: "Walmart",
            url: "https://test-walmart.com",
            city: "Chicago",
            state: "IL",
            postal_code: "60601",
            appointments: [
              VaccineSpotter::Structs::Appointment.new(vaccine_types: ["jj"])
            ]
          ),
          VaccineSpotter::Structs::Location.new(
            name: "Bell",
            provider: "CVS",
            url: "https://cvs-test.com",
            city: "Chicago",
            state: "IL",
            postal_code: "60613",
            appointments: [
              VaccineSpotter::Structs::Appointment.new(vaccine_types: ["jj", "pfizer"]),
              VaccineSpotter::Structs::Appointment.new(vaccine_types: ["jj", "moderna"]),
            ]
          ),
        ]
      }

      it "provides a summary of available appointments" do
        expect(described_class.display(locations)).to match(
          a_string_including(
            "Found a total of 3 appointments! _Due to message limits, less results might be displayed_.",
            "[Walmart Taco](https://test-walmart.com) has the following appointments available:",
            "- 1 appointment in 60601",
            "[CVS Bell](https://cvs-test.com) has the following appointments available:",
              "- 2 appointments in 60613",
          )
        )
      end

      it "truncates the message within the character limit" do
        locations = 1_000.times.map do
          VaccineSpotter::Structs::Location.new(
            name: "Taco Bell",
            provider: "Walmart",
            url: "https://test-walmart.com",
            city: "Chicago",
            state: "IL",
            postal_code: "60601",
            appointments: [
              VaccineSpotter::Structs::Appointment.new(vaccine_types: ["jj"])
            ]
          )
        end

        expect(described_class.display(locations).size).to be < VaccineSpotter::Result::MessageCharacterLimit
      end
    end
  end
end
