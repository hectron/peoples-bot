require "stringio"

module Commands
  module Vaccines
    class Result
      class << self
        def display(providers)
          return if providers.none?

          <<~MSG.strip
            There's #{providers.size} provider(s) where you can get an appointment to receive a vaccination:

            #{providers.map { |p| "- [#{display_provider(p)}](#{build_url_for(p)})" }.join("\n")}
          MSG
        end

        private

        def display_provider(provider)
          io = StringIO.new
          io << "#{provider.name} located at "
          io << "#{provider.address1} #{provider.city}, #{provider.state} #{provider.zipcode} "
          io << "(_about #{provider.distance} miles away_). "
          io << "Phone Number: #{provider.phone}"
          io.string
        end

        def build_url_for(provider)
          "#{ENV["PROVIDER_URL"]}/?id=#{provider.guid}"
        end
      end
    end
  end
end
