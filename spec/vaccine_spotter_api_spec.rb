require "spec_helper"
require_relative "../vaccine_spotter_api"
require_relative "../constants"

describe VaccineSpotterApi do
  CURRENT_PATH = File.expand_path(File.dirname(__FILE__)).freeze

  describe "#find_in" do
    before do
      fixture = File.read(File.join(CURRENT_PATH, "fixtures", "states_il_response.json"))
      allow(Net::HTTP).to receive(:get).and_return(fixture)

      allow($stdout).to receive(:puts)
    end

    it "calls the API to the correct state" do
      expect(Net::HTTP).to receive(:get).with(URI("#{VaccineSpotterApi::API_URL}/IL.json"))

      VaccineSpotterApi.find_in("IL", vaccine_type: nil)
    end

    VACCINE_TYPES.each do |vaccine_type|
      it "returns appointments for #{vaccine_type}" do
        locations = VaccineSpotterApi.find_in("IL", vaccine_type: vaccine_type)

        expect(locations).to all(
          be_a(Location).and have_attributes(
            appointments: all(
              be_a(Appointment).and have_attributes(
                vaccine_types: include(vaccine_type),
              )
            )
          )
        )
      end
    end

    it "filters the results by zipcode" do
      locations = VaccineSpotterApi.find_in("IL", zipcodes: ["60601"])

      expect(locations).to be_empty

      locations = VaccineSpotterApi.find_in("IL", zipcodes: ["60453"])

      expect(locations).not_to be_empty
    end
  end
end
