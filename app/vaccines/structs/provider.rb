module Vaccines
  module Structs
    class Provider
      attr_reader :guid, :name, :address1, :address2, :city, :state, :zipcode, :phone,
                  :distance, :lat, :long, :accepts_walk_ins, :appointments_available, :in_stock

      def self.from_search_response(response)
        response["providers"].map do |provider|
          digits = provider["phone"].scan(/\d/)
          phone = "(#{digits[0..2].join}) #{digits[3..5].join}-#{digits[6..9].join}" if digits.any?

          new(
            guid: provider["guid"],
            name: provider["name"],
            address1: provider["address1"],
            address2: provider["address2"],
            city: provider["city"],
            state: provider["state"],
            zipcode: provider["zip"],
            phone: phone,
            distance: provider["distance"],
            lat: provider["lat"],
            long: provider["long"],
            accepts_walk_ins: provider["accepts_walk_ins"],
            appointments_available: provider["appointments_available"].downcase == "true",
            in_stock: provider["in_stock"],
          )
        end
      end

      def initialize(guid: nil, name: nil, address1: nil, address2: nil, city: nil, state: nil, zipcode: nil,
                     phone: nil, distance: nil, lat: nil, long: nil,
                     accepts_walk_ins: false, appointments_available: false, in_stock: false)
        @guid = guid
        @name = name
        @address1 = address1
        @address2 = address2
        @city = city
        @state = state
        @zipcode = zipcode
        @phone = phone
        @distance = distance
        @lat = lat
        @long = long
        @accepts_walk_ins = accepts_walk_ins
        @appointments_available = appointments_available
        @in_stock = in_stock
      end
    end
  end
end
