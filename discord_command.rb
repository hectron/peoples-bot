class DiscordCommand
  def initialize(args)
    @args = args
  end

  def city
    @city ||= begin
                if string_args.any?
                  string_args.join(" ")
                else
                  nil
                end
              end
  end

  def zipcodes
    @zipcodes ||= integer_args
  end

  private

  def string_args
    @string_args ||= parsed_args[:strings]
  end

  def integer_args
    @integer_args ||= parsed_args[:integers]
  end

  def parsed_args
    @parsed_args ||= begin
                       @args.each_with_object({ strings: [], integers: [] }) do |arg, parsed_args|
                         stripped_arg = arg.strip

                         next if stripped_arg.empty?

                         if stripped_arg.to_i == 0
                           parsed_args[:strings].push(stripped_arg)
                         else
                           parsed_args[:integers].push(stripped_arg)
                         end
                       end
                     end
  end
end
