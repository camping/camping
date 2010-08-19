require 'test_helper'
require 'camping'

Camping.goes :Routes

module Routes::Controllers
  class Index
    def get
      R(Style)
    end
  end
  
  class Style < R '/style\.css'
  end
end

class Routes::Test < TestCase
  def test_backslash
    get '/'
    assert_body '/style.css'
  end
end
