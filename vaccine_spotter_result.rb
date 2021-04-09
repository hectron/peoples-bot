class VaccineSpotterResult
  # @param locations [Array<Location>]
  def self.display(locations)
    return "Did not find any appointments." if locations.none?

    locations.map do |location|
      msg = <<~MSG.strip
        Found #{location.appointments.size} appointment(s) for the #{location.vaccine_types.join(" and ")} vaccine at #{location.name} (#{location.provider}) - #{location.city}, #{location.state} #{location.postal_code}

        Appointment URL: #{location.url}
      MSG
    end.join("\n\n")
  end
end
