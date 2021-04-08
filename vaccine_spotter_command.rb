require "pry"

class VaccineSpotterCommand
  attr_reader :state, :zipcodes

  def self.parse(arguments)
    clean_args = arguments.split(" ").flat_map do |arg|
      arg.strip.split(",").map {|entry| entry.gsub(/,/, "") }
    end

    state = nil
    zipcodes = []

    if clean_args[0].length == 2
      state = clean_args[0]

      if clean_args.size > 1
        zipcodes = clean_args[1..-1]
      end
    else
      zipcodes = clean_args
    end

    new(state, zipcodes)
  end

  def initialize(state, zipcodes = [])
    @state = state
    @zipcodes = zipcodes
  end
end
