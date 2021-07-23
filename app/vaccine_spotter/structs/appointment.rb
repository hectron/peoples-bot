module VaccineSpotter
  module Structs
    Appointment = Struct.new(:time, :vaccine_types, keyword_init: true)
  end
end
