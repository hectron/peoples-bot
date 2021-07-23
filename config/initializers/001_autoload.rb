# These paths are all relative to the application root"
autoload_paths = %w(
  app
)

autoload_paths.each do |path|
  Dir
    .glob(File.join(Application.root, path, "**", "*.rb"))
    .sort_by {|f| f.count("/") } # sorts files breadth first
    .each { |file| require file }
end
