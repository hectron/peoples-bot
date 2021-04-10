class VaccineSpotterResult
  MESSAGE_CHARACTER_LIMIT = 2_000

  # @param locations [Array<Location>]
  def self.display(locations)
    return "Did not find any appointments." if locations.none?

    total_appointments = locations.sum { |location| location.appointments.size }
    output = if total_appointments.size == 1
               "Found a total of #{total_appointments} appointment!"
             else
               "Found a total of #{total_appointments} appointments!"
             end

    locations.each do |location|
      msg = <<~MSG.strip
        #{location.appointments.size} appointment(s) for the #{location.vaccine_types.join(" and ")} vaccine at #{location.name} (#{location.provider}) - #{location.city}, #{location.state} #{location.postal_code}
        Appointment URL: #{location.url}
      MSG

      if (output + msg).size < MESSAGE_CHARACTER_LIMIT
        output += "\n\n"
        output += msg
      else
        break
      end
    end

    output
  end
end
