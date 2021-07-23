require "json"
require "net/http"

module VaccineSpotter
  class Api
    Url = "https://www.vaccinespotter.org/api/v0/states".freeze

    def self.find_in(state:, vaccine_type: nil, city: nil, zipcodes: [])
      new(state, vaccine_type, city, zipcodes).find
    end

    def initialize(state, vaccine_type, city, zipcodes)
      @state = state
      @vaccine_type = vaccine_type
      @city = city
      @zipcodes = zipcodes
    end

    def find
      uri = URI("#{Url}/#{@state}.json")
      data = JSON.parse(Net::HTTP.get(uri))

      data["features"].each_with_object([]) do |feature, locations|
        properties = feature.dig("properties")

        next unless valid_properties?(properties)
        relevant_appointments = extract_valid_appointments(properties["appointments"])
        next unless relevant_appointments.any?

        locations << VaccineSpotter::Structs::Location
          .with_properties_and_appointments(
            properties,
            relevant_appointments
          )
      end
    end

    def extract_valid_properties(properties)
      return false unless properties["appointments_available"]
      return false if @vaccine_type && !properties["appointment_vaccine_types"][@vaccine_type]
      return false if @city && properties["city"]&.downcase != @city
      return false if @zipcodes.any? && !@zipcodes.include?(properties["postal_code"])

      true
    end

    def extract_relevant_appointments(appointments)
      appointments.reject do |appointment|
        next true unless appointment.has_key?("vaccine_types")
        next false if @vaccine_type.nil?
        !appointment["vaccine_types"].include?(@vaccine_type)
      end
    end
  end
end
