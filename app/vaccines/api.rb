require "json"
require "net/http"

require_relative "../services/mapbox/api"
require_relative "./structs/provider"

module Vaccines
  class Api
    attr_reader :vaccine_guid

    SupportedRadiuses = [1, 5, 10, 25, 50].freeze # miles

    def initialize(vaccine_guid)
      @vaccine_guid = vaccine_guid
    end

    def find_in(postal_code:, radius: 5)
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
      uri = URI("#{api_url}/provider-locations/search?#{query_string}")

      response = get(uri)

      if response.code == "200"
        json_response = JSON.parse(response.body)
        Vaccines::Structs::Provider.from_search_response(json_response)
        else
        {}
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

    def api_url
      @api_url ||= ENV["VACCINE_API_URL"]
    end
  end
end
