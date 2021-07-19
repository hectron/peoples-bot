module BeachSand; end

files = Dir.glob(File.join(__dir__, "**", "*.rb"))

files.each do |file|
  require file unless file == __FILE__
end
