require 'test_helper'
require 'camping'

Camping.goes :Loggy

Loggy.pack Gear::Firewatch

module Loggy::Controllers

  class Index
    def get
      # @env['rack.errors'] = StringIO.new
      log.debug("Created Logger")
      log.info("Program Started")
      log.warn("Nothing to do!")
      log "what up"
    end
  end
end

class Loggy::Test < TestCase

  def logs
    File.read Dir["./**/logs/development.log"].first
  end

  def after_all
    `rm -rf logs` if File.exist?('logs/development.log')
    `rm -rf logs` if File.exist?('logs/formatter.log')
    `rm -rf logs` if File.exist?('logs/production.log')
    super
  end

  def test_logging
    get '/'
    assert_log "Program Started"
    assert_log "INFO"
  end

  def test_log_levels
    get '/'
    assert(/(INFO).*Program Started$/.match?(logs), "Log level of INFO not found.")
    assert(/(WARN).*Nothing to do!$/.match?(logs), "Log level of WARN not found.")
  end

  def test_log_on_error
    get '/'
    assert_raises {
      raise "[Error]: There was a big error and I don't like it."
    }
  end

  def test_change_log_location
    Camping::Firewatch.logger = Dry.Logger(:Camping, template: Camping::Firewatch::default_template).add_backend(stream: "logs/production.log")
    puts Camping::Firewatch.logger
    get '/'
    lags = File.read Dir["./**/logs/production.log"].first
    assert(/(INFO).*Program Started$/.match?(lags), "Log level of INFO not found.")

    # the end of the test means we set it back.
    Camping::Firewatch.logger = Dry.Logger(:Camping, template: Camping::Firewatch::default_template).add_backend(stream: "logs/development.log")
  end

  # def test_changing_loggging_formatter
  #   logger = Dry.Logger(:Camping, formatter: :rack).add_backend(stream: "logs/formatter.log")
  #   get '/'
  #   assert(/(INFO).*Program Started$/.match?(logs), "Log level of INFO not found.")
  # end

end
