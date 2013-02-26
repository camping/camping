require 'test_helper'
require 'camping'

Camping.goes :Simple

module Simple::Controllers
  class Index
    def get
      "Hello World!"
    end
    
    def post
      "Hello Post!"
    end
    
    def custom
      "Hello Custom!"
    end
  end
  
  class PostN
    def get(id)
      "Post ##{id}"
    end
  end
  
  class MultipleComplexX
    def get(str)
      "Complex: #{str}"
    end
  end
  
  class DateNNN
    def get(year, month, day)
      [year, month, day] * "-"
    end
  end
  
  class Regexp < R '/ohmy/([a-f]+)'
    def get(value)
      value
    end
  end
  
  class Optional < R '/optional', '/optional/([^/]+)'
    def get(value = "default")
      "Optional: #{value}"
    end
  end

  class Weird
    def get
      redirect MultipleComplexX, 'hello%#/world'
    end
  end

  class NilResponse < R '/nil' 
    def get
      #nil response
    end
  end

  class NotStringResponse < R '/notstring' 
    def get
      123
    end
  end

  class IteratableResponse < R '/iter'
    def get 
      [1,2,3]
    end
  end
end

class Simple::Test < TestCase
  def test_index
    get '/'
    assert_body "Hello World!"
    assert_equal "text/html", last_response.headers['Content-Type']
    
    post '/'
    assert_body "Hello Post!"
  end
  
  def test_post
    get '/post/1'
    assert_body "Post #1"
    
    get '/post/2'
    assert_body "Post #2"
    
    get '/post/2-oh-no'
    assert_status 404
  end
  
  def test_complex
    get '/multiple/complex/Hello'
    assert_body "Complex: Hello"
  end
  
  def test_date
    get '/date/2010/04/01'
    assert_body "2010-04-01"
  end
  
  def test_regexp
    get '/ohmy/cafebabe'
    assert_body "cafebabe"
    
    get '/ohmy/CAFEBABE'
    assert_status 404
  end
  
  def test_optional
    get '/optional'
    assert_body "Optional: default"
    
    get '/optional/override'
    assert_body "Optional: override"
  end

  def test_weird
    get '/weird'
    follow_redirect!
    assert_body 'Complex: hello%#/world'
  end

  def test_nil_response 
    get '/nil'
    assert_body ""
    assert_equal "text/html", last_response.headers['Content-Type']
  end

  def test_not_string_response
    get '/notstring'
    assert_body "123"
    assert_equal "text/html", last_response.headers['Content-Type']
  end

  def test_iteratable_response
    get '/iter'
    assert_body "123"
    assert_equal "text/html", last_response.headers['Content-Type']
  end
end
