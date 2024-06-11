$:.unshift File.dirname(__FILE__) + '/../'
# shift to act like we're in the regular degular directory

begin
  require 'rubygems'
rescue LoadError
end

require 'camping'
require 'minitest/autorun'
require 'minitest'
require 'rack/test'
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

class TestCase < Minitest::Test
  include Rack::Test::Methods

  def self.inherited(mod)
    mod.app = Object.const_get(mod.to_s[/w+/])
    super
  end

  class << self
    attr_accessor :app
  end

  def body() last_response.body end
  def app()  self.class.app     end

  def assert_reverse
    begin
      yield
    rescue Exception
    else
      assert false, "Block didn't fail"
    end
  end

  def assert_body(str)
    case str
    when Regexp
      assert_match(str, last_response.body.strip)
    else
      assert_equal(str.to_s, last_response.body.strip)
    end
  end

  def assert_status(code)
    assert_equal(code, last_response.status)
  end

  def test_silly; end

end
