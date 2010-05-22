$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'rubygems'
rescue LoadError
end

require 'camping'
require 'test/unit'
require 'rack/test'

class TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
    
  def self.inherited(mod)
    mod.app = Object.const_get(mod.to_s[/\w+/])
  end
  
  class << self
    attr_accessor :app
  end
  
  def app()  self.class.app     end
    
  def assert_body(str)
    assert_equal(str, last_response.body)
  end
  
  def assert_status(code)
    assert_equal(code, last_response.status)
  end
  
  def test_noop
  end
end
