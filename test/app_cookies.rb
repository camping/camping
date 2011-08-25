require 'test_helper'
require 'camping'

Camping.goes :Cookies

module Cookies::Controllers
  class One
    def get
      @cookies.simple = '42'
      @cookies.set :complex, '43'
      @cookies.set :past, 'past', :expires => Time.now - 5
      render :show
    end
  end

  class Two
    def get
      render :show
    end
  end

  class Old
    def get
      @cookies.simple = '42'
      @cookies.complex = { :value => '43' }
      @cookies.past = { :value => 'past', :expires => Time.now - 5 }
      @cookies.past.class.name
    end
  end
end

module Cookies::Views
  def show
    @cookies.values_at('simple', 'complex', 'past').inspect
  end
end

class Cookies::Test < TestCase
  def test_cookies
    get '/one'
    assert_body '["42", "43", "past"]'

    get '/two'
    assert_body '["42", "43", nil]'
  end

  def test_backward_compatible
    get '/old'
    assert_body 'Hash'

    get '/two'
    assert_body '["42", "43", nil]'
  end

  def test_path
    get '/one', {}, 'SCRIPT_NAME' => '/mnt'
    assert_body '["42", "43", "past"]'
    assert_equal 3, last_response.headers["Set-Cookie"].scan('path=/mnt/').size
  end
end

