require 'test_helper'
require 'camping'
require 'camping/commands'

Camping.goes :Routes

module Routes::Controllers
  class Index
    def get
      R(Style)
    end
  end

  class Style < R '/style\.css'
  end

  class PageX
      def get
      end

      def post
      end
  end

end

class Routes::Test < TestCase
  def test_backslash
    get '/'
    assert_body '/style.css'
  end

  def test_routes_helper
    #Make sure to call the route maker.
    Camping.routes
    routes = Camping::Commands.routes Camping::Apps[8], false
    assert_equal routes.count, 3, "Routes are not numbered correctly"
    assert routes[0].to_s == "Index GET      /index", "Routes do not include: #{routes[0].to_s}"
    assert routes[1].to_s == "PageX GET      /page/:String", "Routes do not include: #{routes[1].to_s}"
    assert routes[2].to_s == "PageX POST     /page/:String", "Routes do not include: #{routes[2].to_s}"
  end
end
