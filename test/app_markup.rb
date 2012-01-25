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

  class AutoPrepend
    def get
      mab do
        img :src => '/hello.png'
      end
    end
  end

  class Compat < R '/compat/(.*?)'
    def get(type)
      mab do
        send(type) do
          body { h1 'Nice' }
        end
      end
    end
  end

  class CompatHelpers
    def get
      mab do
        helpers.R CompatHelpers
      end
    end
  end
end

module Markup::Views
  def index
    h1 "Welcome!"
  end
  
  def layout
    self << '<!DOCTYPE html>'
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
    assert_body %r{\A<!DOCTYPE html>}
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

  def test_auto_prepend
    get '/auto/prepend', {}, 'SCRIPT_NAME' => '/mount'
    assert_body '<img src="/mount/hello.png">'
  end

  def test_compat
    warning = "xhtml_strict is no longer supported (or an active standard); using HTML5 instead\n"

    assert_output '', warning * 3 do
      get '/compat/xhtml_strict'
      assert_body '<!DOCTYPE html><html><body><h1>Nice</h1></body></html>'

      get '/compat/xhtml_transitional'
      assert_body '<!DOCTYPE html><html><body><h1>Nice</h1></body></html>'

      get '/compat/xhtml_frameset'
      assert_body '<!DOCTYPE html><html><body><h1>Nice</h1></body></html>'
    end
  end

  def test_compat_helpers
    get '/compat/helpers'
    assert_body '/compat/helpers'
  end
end

