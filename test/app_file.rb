require 'test_helper'
require 'camping'

Camping.goes :FileSource

module FileSource::Controllers
  class Index
    def get
      FileSource.options[:__FILE__]
    end
  end
end

class FileSource::Test < TestCase
  def test_source
    get '/'
    assert_body __FILE__
  end

  def test_file
    get '/style.css'
    assert_body "* { margin: 0; padding: 0 }"
    assert_equal "text/css", last_response.headers['Content-Type']

    get '/test.foo'
    assert_body "Hello"
    assert_equal "text/html", last_response.headers['Content-Type']

    get '/test'
    assert_body "No extension"
    assert_equal "text/html", last_response.headers['Content-Type']
  end
end

__END__

@@ /style.css
* { margin: 0; padding: 0 }

@@ /test.foo
Hello

@@ /test
No extension

