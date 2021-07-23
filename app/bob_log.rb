require "forwardable"
require "logger"

class BobLog
  # :device is the log device, meaning StringIO, disk, etc.
  #   @see https://ruby-doc.org/stdlib-2.7.0/libdoc/logger/rdoc/Logger.html
  #
  # :level is the log level to display. If this is set to warn, and `.debug` messages are called, they will not be
  #   written to the log device.
  attr_accessor :device, :level

  class << self
    extend Forwardable

    def_delegators :@logger, :debug, :info, :warn, :error

    def configure
      # treat this instance like a singleton variable
      @instance = new

      yield @instance

      set_logger!
    end

    private

    def set_logger!
      @logger = Logger.new(@instance.device, level: @instance.level)
    end
  end

  # Set a default configuration
  # TODO move this into an initializer of sorts
  @instance = configure do |logger|
    logger.device = $stdout
    logger.level = Logger::WARN
  end
end
