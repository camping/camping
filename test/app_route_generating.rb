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
    collection = Camping::Commands.routes Camping::Apps[8], true
    routes = collection.routes.map(&:to_s)
    assert_equal routes.count, 3, "Routes are not numbered correctly"
    assert (routes.include? "get: /page/([^/]+)"), "Routes do not include: [get: /page/([^/]+)]"
    assert (routes.include? "post: /page/([^/]+)"), "Routes do not include: [post: /page/([^/]+)]"
    assert (routes.include? "get: /"), "Routes do not include: [get: /]"
  end
end
