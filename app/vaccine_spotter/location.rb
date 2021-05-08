module VaccineSpotter
  Location = Struct.new(:name, :provider, :url, :city, :state, :postal_code, :appointments, keyword_init: true) do
    def vaccine_types
      appointments.flat_map(&:vaccine_types).uniq
    end
  end
end
