require_relative "../../../app/vaccine_spotter/api"
require_relative "../../../app/constants"

describe VaccineSpotter::Api do
  CURRENT_PATH = File.expand_path(File.dirname(__FILE__)).freeze

  describe "#find_in" do
    before do
      fixture = File.read(File.join(CURRENT_PATH, "..", "..", "fixtures", "states_il_response.json"))
      allow(Net::HTTP).to receive(:get).and_return(fixture)

      allow($stdout).to receive(:puts)
    end

    it "calls the API to the correct state" do
      expect(Net::HTTP).to receive(:get).with(URI("#{VaccineSpotter::Api::API_URL}/IL.json"))

      VaccineSpotter::Api.find_in(state: "IL")
    end

    VACCINE_TYPES.each do |vaccine_type|
      it "returns appointments for #{vaccine_type}" do
        locations = VaccineSpotter::Api.find_in(state: "IL", vaccine_type: vaccine_type)

        expect(locations).to all(
          be_a(VaccineSpotter::Location).and have_attributes(
            appointments: all(
              be_a(VaccineSpotter::Appointment).and have_attributes(
                vaccine_types: include(vaccine_type),
              )
            )
          )
        )
      end
    end

    it "filters the results by zipcode" do
      locations = VaccineSpotter::Api.find_in(state: "IL", zipcodes: ["60601"])
      expect(locations).to be_empty

      locations = VaccineSpotter::Api.find_in(state: "IL", zipcodes: ["60453"])
      expect(locations).not_to be_empty
    end

    it "filters by city" do
      locations = VaccineSpotter::Api.find_in(state: "IL", city: "chicago")
      expect(locations).not_to be_empty
    end

    it "filters by both city and zip" do
      locations = VaccineSpotter::Api.find_in(state: "IL", city: "chicago", zipcodes: ["60613"])
      expect(locations).to be_empty

      locations = VaccineSpotter::Api.find_in(state: "IL", city: "chicago", zipcodes: ["60613", "60640"])
      expect(locations).not_to be_empty
    end
  end
end
