describe Vaccines::Structs::Provider do
  describe ".from_search_response" do
    let(:response) do
      json_response = File.read(File.join(Application.root, "spec", "fixtures", "vaccines_api_provider_locations.json"))
      JSON.parse(json_response)
    end

    it "returns a list of providers" do
      expect(described_class.from_search_response(response))
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
end
