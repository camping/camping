require 'test_helper'
require 'camping'
require 'camping/firewatch'

Camping.goes :Loggy

# Loggy.use ::Gear::Logger, Loggy
Loggy.pack Gear::Firewatch

Loggy.set :logger, {file: 'log/development.log'}

module Loggy::Controllers
  class Index
    def get
      # @env['rack.errors'] = StringIO.new
      log.debug("Created Logger")
      log.info("Program Started")
      log.warn("Nothing to do!")
    end
  end
end

class Loggy::Test < TestCase
  def test_logging
    get '/'
    # puts Dir["./logs/development.log"]
    assert_log "INFO"
    # assert_log %r{\[INFO}
    # assert_log %r{Program Started}
    # assert_log %r{\[WARN}
    # assert_log %r{Nothing to do}
  end
end
