# These paths are all relative to the application root"
autoload_paths = %w(
  app
)

autoload_paths.each do |path|
  Dir.glob(File.join(Application.root, path, "**", "*.rb")).sort.each do |file|
    require file
  end
end
