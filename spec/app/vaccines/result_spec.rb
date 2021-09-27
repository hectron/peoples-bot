describe Vaccines::Result do
  describe ".display" do
    context "when no providers are passed" do
      it "returns a warning string" do
        expect(described_class.display([])).to eq("No providers were given.")
      end
    end

    context "when providers are passed in" do
      it "returns a message listing locations with appointments" do
        providers = Vaccines::Structs::Provider.from_search_response(
          {
            "providers" => [
              {
                "name" => "Foxtrot",
                "address1" => "200 N. Wells St",
                "city" => "Chicago",
                "state" => "IL",
                "zip" => "60601",
                "phone" => "773.555.1111",
                "appointments_available" => "TRUE",
                "distance" => 0.5
              }
            ]
          },
        )

        expect(described_class.display(providers)).to eq(<<~MSG.strip)
          There's 1 provider(s) where you can get an appointment to receive a vaccination:

          - Foxtrot located at 200 N. Wells St Chicago, IL 60601 (_about 0.5 miles away_). Phone Number: (773) 555-1111
        MSG
      end
    end
  end
end
