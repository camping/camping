$:.unshift File.dirname(__FILE__) + '/../lib'

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

class TestCase < MiniTest::Unit::TestCase
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
