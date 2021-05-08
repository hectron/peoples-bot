module VaccineSpotter
  Appointment = Struct.new(:time, :vaccine_types, keyword_init: true)
end
