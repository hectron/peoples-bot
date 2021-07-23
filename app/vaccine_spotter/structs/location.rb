module VaccineSpotter
  module Structs
    Location = Struct.new(:name, :provider, :url, :city, :state, :postal_code, :appointments, keyword_init: true) do
      def vaccine_types
        appointments.flat_map(&:vaccine_types).uniq
      end

      def self.with_properties_and_appointments(properties, appointments)
        new(
          name: properties["name"],
          provider: properties["provider"],
          url: properties["url"],
          city: properties["city"],
          state: properties["state"],
          postal_code: properties["postal_code"],
          appointments: appointments.map do |appointment|
            VaccineSpotter::Structs::Appointment.new(
              time: appointment["time"],
              vaccine_types: appointment["vaccine_types"],
            )
          end
        )
      end
    end
  end
end
