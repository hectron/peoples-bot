module Services
  module Mapbox
    class Api
      Url = "https://api.mapbox.com/geocoding/v5/mapbox.places".freeze
      AccessToken = ENV.fetch("MAPBOX_TOKEN").freeze

      class << self
        def geocode_postal_code(postal_code)
          uri = URI("#{Url}/#{postal_code}.json?#{params}")
          response = Net::HTTP.get(uri)
          json_response = JSON.parse(response, { object_class: OpenStruct })
          json_response
            .features
            .find { |feature| feature.place_type.include?("postcode") }
            &.center
        end

        def params
          @params ||= URI.encode_www_form({ country: :us, types: :postcode, access_token: AccessToken })
        end
      end
    end
  end
end
