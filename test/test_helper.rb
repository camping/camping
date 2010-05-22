$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'rubygems'
rescue LoadError
end

require 'camping-unabridged'
require 'test/unit'
require 'rack/test'

class TestCase < Test::Unit::TestCase
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
    rescue
    else
      assert false, "Block didn't fail"
    end
  end
    
  def assert_body(str)
    case str
    when Regexp
      assert_match(str, last_response.body)
    else
      assert_equal(str.to_s, last_response.body)
    end
  end
  
  def assert_status(code)
    assert_equal(code, last_response.status)
  end
  
  def test_noop
  end
end
