require 'test_helper'
require 'camping'
require 'camping/session'

Camping.goes :Sessions

module Sessions
  include Camping::Session
end

module Sessions::Controllers
  class One
    def get
      @state.clear
      @state.one = 42
      redirect R(Two)
    end
  end
  
  class Two
    def get
      @state.two = 56
      redirect R(Three)
    end
  end
  
  class Three
    def get
      @state.three = 99
      @state.values_at("one", "two", "three").inspect
    end
  end
end

class Sessions::Test < TestCase
  def test_session
    get '/one'
    follow_redirect!
    follow_redirect!
    assert_body "[42, 56, 99]"
  end
end
