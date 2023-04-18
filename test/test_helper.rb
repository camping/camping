$:.unshift File.dirname(__FILE__) + '/../lib'
$VERBOSE = nil

begin
  require 'rubygems'
rescue LoadError
end

if ENV['ABRIDGED']
  require 'camping'
else
  require 'camping-unabridged'
end

require 'minitest/autorun'
require 'rack/test'
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

class TestCase < MiniTest::Test
  include Rack::Test::Methods

  def self.inherited(mod)
    mod.app = Object.const_get(mod.to_s[/\w+/])
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

  def assert_body(str, message="")
    case str
    when Regexp
      assert_match(str, last_response.body.strip, message)
    else
      assert_equal(str.to_s, last_response.body.strip, message)
    end
  end

  def assert_status(code, message="")
    assert_equal(code, last_response.status, message)
  end

  def test_silly; end
end
