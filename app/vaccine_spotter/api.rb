require "json"
require "net/http"

require_relative "./appointment"
require_relative "./location"

module VaccineSpotter
  class Api
    API_URL = "https://www.vaccinespotter.org/api/v0/states".freeze

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
      uri = URI("#{API_URL}/#{@state}.json")
      data = JSON.parse(Net::HTTP.get(uri))

      data["features"].each_with_object([]) do |feature, locations|
        properties = feature.dig("properties")
        next unless properties["appointments_available"]
        next if @vaccine_type && !properties["appointment_vaccine_types"][@vaccine_type]
        next if @city && properties["city"]&.downcase != @city
        next if @zipcodes.any? && !@zipcodes.include?(properties["postal_code"])

        relevant_appointments = properties["appointments"].reject do |appointment|
          next true unless appointment.has_key?("vaccine_types")
          next false if @vaccine_type.nil?
          !appointment["vaccine_types"].include?(@vaccine_type)
        end

        if relevant_appointments.any?
          locations << VaccineSpotter::Location.new(name: properties["name"],
                                                    provider: properties["provider"],
                                                    url: properties["url"],
                                                    city: properties["city"],
                                                    state: properties["state"],
                                                    postal_code: properties["postal_code"],
                                                    appointments: relevant_appointments.map do |appointment|
                                                      VaccineSpotter::Appointment.new(time: appointment["time"], vaccine_types: appointment["vaccine_types"])
                                                    end)
        end
      end
    end
  end
end
