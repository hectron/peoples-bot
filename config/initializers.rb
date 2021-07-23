Dir.glob(File.join(__dir__, "**", "*.rb"))
  .sort
  .reject { |file| file == __FILE__ } # reject this file
  .each { |file| require file }
