require "json"
require "net/http"
require "pry"

require_relative "../services/mapbox/api"
require_relative "./structs/provider"

module Vaccines
  class Api
    Url = "https://api.us.castlighthealth.com/vaccine-finder/v1".freeze

    SupportedRadiuses = [1, 5, 10, 25, 50].freeze # miles

    class << self
      def find(vaccine_guid:, postal_code:, radius: 5)
        unless SupportedRadiuses.include?(radius)
          raise "Invalid radius `#{radius}`. Supported radiuses: #{SupportedRadiuses}"
        end

        coordinates = Services::Mapbox::Api.geocode_postal_code(postal_code)
        query_params = {
          medicationGuids: vaccine_guid,
          long: coordinates[0],
          lat: coordinates[1],
          appointments: true,
          radius: radius
        }

        query_string = URI.encode_www_form(query_params)
        uri = URI("#{Url}/provider-locations/search?#{query_string}")

        response = get(uri)

        if response.code == "200"
          json_response = JSON.parse(response.body)
          Vaccines::Structs::Provider.from_search_response(json_response)
        else
          {}
        end
      end

      def vaccine_types
        # Can these be cached for some period of time?
        uri = URI("#{Url}/medications?category=covid")
        response = get(uri)

        if response.code == "200"
          JSON.parse(response.body, { object_class: OpenStruct })
        else
          []
        end
      end

      private

      def get(uri)
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          request = Net::HTTP::Get.new(uri)

          request["Accept-Language"] = "en-US,en;q=0.9"
          request["Accept"] = "application/json, text/plain, */*"
          request["User-Agent"] = "Mozilla/5.0"

          http.request(request)
        end
      end
    end
  end
end
