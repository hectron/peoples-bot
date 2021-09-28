describe Vaccines::Api do
  let(:mock_http) { Net::HTTP.new(url.host) }

  before do
    stub_env({ "VACCINE_API_URL" => "https://my.api.url.com" })
    allow(Net::HTTP).to receive(:start).and_yield(mock_http)
  end

  describe ".find" do
    let(:url) { URI("#{described_class.send(:api_url)}/provider-locations/search") }

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
end
