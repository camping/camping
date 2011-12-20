require 'test_helper'
require 'camping'

Camping.goes :Markup

module Markup::Controllers
  class Index
    def get
      render :index
    end
  end
  
  class NoLayout
    def get
      render :index, :layout => false
    end
  end

  class MountPath
    def get
      mab do
        a "hello", :href => R(Index)
      end
    end
  end
end

module Markup::Views
  def index
    h1 "Welcome!"
  end
  
  def layout
    html do
      head do
        title "Web Page"
      end
      
      body { yield }
    end
  end
end

class Markup::Test < TestCase
  def test_render
    get '/'
    assert_body %r{<h1>Welcome!</h1>}
    assert_body %r{<title>Web Page</title>}
  end
  
  def test_no_layout
    get '/no/layout'
    assert_body %r{<h1>Welcome!</h1>}
    
    assert_reverse do
      assert_body %r{<title>Web Page</title>}
    end
  end

  def test_mount_path
    get '/mount/path', {}, 'SCRIPT_NAME' => '/hello'
    assert_body '<a href="/hello/">hello</a>'
  end
end
