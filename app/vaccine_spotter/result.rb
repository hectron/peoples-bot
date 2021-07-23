require "erb"

module VaccineSpotter
  class Result
    MessageCharacterLimit = 2_000

    # @param locations [Array<Location>]
    def self.display(locations)
      return "Did not find any appointments." if locations.none?
      total_appointments = locations.sum { |location| location.appointments.size }
      found_appointments_message = if total_appointments.size == 1
                 "Found a total of #{total_appointments} appointment!"
               else
                 "Found a total of #{total_appointments} appointments! _Due to message limits, less results might be displayed_."
               end

      erb_file = File.read(File.join(__dir__, "templates", "summary.md.erb"))

      ERB
        .new(erb_file, trim_mode: "-")
        .result_with_hash({
          found_appointments_message: found_appointments_message,
          locations: locations
        })
    end
  end
end
