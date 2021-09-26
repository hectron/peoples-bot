describe Vaccines::Api do
  let(:mock_http) { Net::HTTP.new(url.host) }

  before do
    allow(Net::HTTP).to receive(:start).and_yield(mock_http)
  end

  describe ".find" do
    let(:url) { URI("#{described_class::Url}/provider-locations/search") }

    before do
      allow(Services::Mapbox::Api).to receive(:geocode_postal_code).and_return([40.0, -81.0])
    end

    context "a succesful request" do
      let(:fixture) do
        File.read(File.join(Application.root, "spec", "fixtures", "vaccines_api_provider_locations.json"))
      end

      before do
        allow(mock_http).to receive(:request).and_return(
          instance_double(Net::HTTPResponse, code: "200", body: fixture),
        )
      end

      it "returns a list of providers" do
        expect(described_class.find(vaccine_guid: "mock_guid", postal_code: "60601"))
          .to all(be_a(Vaccines::Structs::Provider))
          .and include(
            having_attributes(
              name: "MICHIGAN AVENUE PRIMARY CARE / IMMEDIATE CARE",
              address1: "180 N Michigan Ave #1605",
              address2: "",
              city: "Chicago",
              state: "IL",
              zipcode: "60601",
              phone: nil,
              distance: 0.08,
              lat: 41.885511,
              long: -87.624889,
              accepts_walk_ins: false,
              appointments_available: false,
              in_stock: true,
            ),
            having_attributes(
              name: "CVS Pharmacy, Inc. #04781",
              address1: "205 N Michigan Ave",
              address2: "",
              city: "Chicago",
              state: "IL",
              zipcode: "60601",
              phone: "(312) 938-4091",
              distance: 0.09,
              lat: 41.886098,
              long: -87.624033,
              accepts_walk_ins: true,
              appointments_available: true,
              in_stock: true,
            ),
            having_attributes(
              name: "Walgreens Co. #9438",
              address1: "30 N Michigan Ave LBBY 1",
              address2: "",
              city: "Chicago",
              state: "IL",
              zipcode: "60602",
              phone: "(312) 332-3540",
              distance: 0.14,
              lat: 41.883004,
              long: -87.624772,
              accepts_walk_ins: true,
              appointments_available: true,
              in_stock: true,
            ),
            having_attributes(
              name: "Walgreens Co. #15196",
              address1: "Flair Tower, 151 N State St FL 1ST",
              address2: "",
              city: "Chicago",
              state: "IL",
              zipcode: "60601",
              phone: "(312) 863-4249",
              distance: 0.21,
              lat: 41.884799,
              long: -87.627623,
              accepts_walk_ins: true,
              appointments_available: true,
              in_stock: true,
            ),
            having_attributes(
              name: "CVS Pharmacy, Inc. #17643",
              address1: "1 S State St",
              address2: "",
              city: "Chicago",
              state: "IL",
              zipcode: "60603",
              phone: "(312) 279-2134",
              distance: 0.3,
              lat: 41.881792,
              long: -87.627525,
              accepts_walk_ins: true,
              appointments_available: true,
              in_stock: true,
            ),
          )
      end
    end

    context "an unsuccessful request" do
      before do
        allow(mock_http).to receive(:request).and_return(instance_double(Net::HTTPResponse, code: "400"))
      end

      it "returns an empty list" do
        expect(described_class.find(vaccine_guid: "mock_guid", postal_code: "60601")).to be_empty
      end
    end

    context "using an invalid radius" do
      it "raises an exception" do
        expect do
          described_class.find(vaccine_guid: "mock_orange", postal_code: "60601", radius: 3)
        end.to raise_error(
          a_string_including(
            "Invalid radius `3`.",
            "Supported radiuses: #{described_class::SupportedRadiuses}",
          ),
        )
      end
    end
  end

  describe ".vaccine_types" do
    let(:url) { URI("#{described_class::Url}/medications?category=covid") }
    let(:fixture) do
      File.read(File.join(Application.root, "spec", "fixtures", "vaccines_api_medications_response.json"))
    end

    context "a successful request" do
      before do
        allow(mock_http).to receive(:request).and_return(instance_double(Net::HTTPResponse, code: "200", body: fixture))
      end

      it "returns a list of vaccines" do
        expect(described_class.vaccine_types).to contain_exactly(
          an_object_having_attributes(
            guid: "779bfe52-0dd8-4023-a183-457eb100fccc",
            name: "Moderna (age 18+)",
            key: "moderna_covid_19_vaccine",
          ),
          an_object_having_attributes(
            guid: "a84fb9ed-deb4-461c-b785-e17c782ef88b",
            name: "Pfizer-BioNTech (age 12+)",
            key: "pfizer_covid_19_vaccine",
          ),
          an_object_having_attributes(
            guid: "784db609-dc1f-45a5-bad6-8db02e79d44f",
            name: "Johnson & Johnson/Janssen (age 18+)",
            key: "j&j_janssen_covid_19_vaccine",
          ),
        )
      end
    end

    context "an unsuccessful request" do
      before do
        allow(mock_http).to receive(:request).and_return(instance_double(Net::HTTPResponse, code: "400"))
      end

      it "returns an empty list" do
        expect(described_class.vaccine_types).to be_empty
      end
    end
  end
end
