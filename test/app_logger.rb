require 'test_helper'
require 'camping'

Camping.goes :Loggy

# Loggy.use ::Gear::Logger, Loggy
Loggy.pack Gear::Firewatch

module Loggy::Controllers
  class Index
    def get
      # @env['rack.errors'] = StringIO.new
      log.debug("Created Logger")
      log.info("Program Started")
      log.warn("Nothing to do!")
      render :index
    end
  end

end

module Loggy::Views
  def index
    h1 "Welcome!"
  end

end

class Loggy::Test < TestCase
  def test_logging
    get '/'
    assert_log %r{INFO -- : Program Started}
    assert_log %r{WARN -- : Nothing to do}
  end
end
