require 'test_helper'
require 'camping'

Camping.goes :Partials
Camping.goes :TiltPartials

module Partials::Controllers
  class Index
    def get
      render :index
    end
  end

  class Partial
    def get
      render :_partial
    end
  end

  class Nolayout
    def get
      render :index, :layout => false
    end
  end

  class Forcelayout
    def get
      render :_partial, :layout => true
    end
  end

  class Nested
    def get
      render :nested
    end
  end
end

# Copy over all controllers
module TiltPartials::Controllers
  Partials::Controllers.constants.each do |const|
    const_set(const, Partials::Controllers.const_get(const).dup)
  end
end

module Partials::Views
  def layout
    body do
      yield
    end
  end

  def index
    h1 "Index"
    _partial
  end

  def _partial
    p "Partial"
  end

  def nested
    h1 "Nested"
    regular
  end

  def regular
    p "Regular"
  end
end

class Partials::Test < TestCase
  def test_underscore_partial
    get '/'
    assert_body "<body><h1>Index</h1><p>Partial</p></body>"
  end

  def test_underscore_partial_only
    get '/partial'
    assert_body "<p>Partial</p>"
  end

  def test_nolayout
    get '/nolayout'
    assert_body "<h1>Index</h1><p>Partial</p>"
  end

  def test_forcelayout
    get '/forcelayout'
    assert_body "<body><p>Partial</p></body>"
  end

  def test_netsted
    get '/nested'
    assert_body "<body><h1>Nested</h1><p>Regular</p></body>"
  end
end

class TiltPartials::Test < Partials::Test
end


__END__
@@ layout.str
<body>#{yield.strip}</body>

@@ index.str
<h1>Index</h1>#{render(:_partial).strip}

@@ _partial.str
<p>Partial</p>

@@ nested.str
<h1>Nested</h1>#{render(:regular).strip}

@@ regular.str
<p>Regular</p>

