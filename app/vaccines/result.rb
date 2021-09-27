require "stringio"

module Vaccines
  class Result
    class << self
      def display(providers)
        return "No providers were given." if providers.none?

        <<~MSG.strip
          There's #{providers.size} provider(s) where you can get an appointment to receive a vaccination:

          #{providers.map { |provider| "- #{display_provider(provider)}" }.join("\n")}
        MSG
      end

      def display_provider(provider)
        io = StringIO.new
        io << "#{provider.name} located at "
        io << "#{provider.address1} #{provider.city}, #{provider.state} #{provider.zipcode} "
        io << "(_about #{provider.distance} miles away_). "
        io << "Phone Number: #{provider.phone}"
        io.string
      end
    end
  end
end
