module VaccineSpotter
  class DiscordCommand
    # Dynamically creates discord commands for each vaccine
    VaccineSpotter::VaccineTypes.map do |vaccine_type|
      klass = Class.new(::DiscordCommand)

      klass.name(vaccine_type.to_sym)
      klass.description("Find #{vaccine_type} vaccines")
      klass.usage(<<~USAGE.strip)
          #{Application.bot_prefix}#{vaccine_type} <STATE> [<CITY> (optional)] <zipcode1> <zipcode2> ... <zipcodeN>

          Examples:
            #{Application.bot_prefix}#{vaccine_type} IL
            #{Application.bot_prefix}#{vaccine_type} IL Chicago
            #{Application.bot_prefix}#{vaccine_type} IL 60601 60613 60657
            #{Application.bot_prefix}#{vaccine_type} IL Chicago 60613 60660
      USAGE

      klass.event_handler ->(_, state, *args) do
        BobLog.info "Command type: #{type}, State: #{state}, Args: #{args.inspect}"

        command = ::Discord::Command.new(args)
        locations = VaccineSpotter::Api.find_in(
          state: state,
          vaccine_type: type,
          city: command.city,
          zipcodes: command.zipcodes,
        )

        VaccineSpotter::Result.display(locations).tap do |msg|
          BobLog.info msg
        end
      end

      VaccineSpotter::DiscordCommand.const_set(VaccineSpotter::PrettyVaccineName[vaccine_type], klass)
    end

    def self.all
      VaccineSpotter::VaccineTypes.map do |vaccine_type|
        VaccineSpotter::DiscordCommand.const_get(VaccineSpotter::PrettyVaccineName[vaccine_type])
      end
    end
  end
end
