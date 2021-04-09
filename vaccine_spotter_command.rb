require "pry"
require_relative "./constants"

class VaccineSpotterCommand
  attr_reader :state, :zipcodes

  def self.parse(arguments)
    clean_args = arguments.split(" ").flat_map do |arg|
      arg.strip.split(",").map {|entry| entry.gsub(/,/, "") }
    end

    state = nil
    zipcodes = []

    if (potential_state = clean_args[0]) && potential_state.length == 2
      if STATES.include?(potential_state.upcase)
        state = potential_state.upcase
      else
        raise ArgumentError, "Could not parse state. Args: #{arguments}"
      end

      if clean_args.size > 1
        zipcodes = parse_zipcodes(clean_args[1..-1])
      end
    else
      raise ArgumentError, "No state found in: #{arguments}"
    end

    new(state, zipcodes)
  end

  def initialize(state, zipcodes = [])
    @state = state
    @zipcodes = zipcodes
  end

  private

  def self.parse_zipcodes(potential_zips)
    potential_zips.map do |zip|
      zip.strip.to_i.to_s.tap do |clean_zip|
        if clean_zip.length != 5
          raise ArgumentError, "Could not parse zipcodes: #{potential_zips}"
        end
      end
    end
  end
end
