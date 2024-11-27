require 'helper'
require 'camping'
require 'camping/commands'

Camping.goes :Routes

module Routes::Controllers
  class Index < R '/'
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

  class Edit < Camper
    def get
    end

    def post
    end
  end

  class Post < R Edit, '/post', '/post/post'
    def get
    end

    def post
    end
  end

  class Bump < Edit
    def get
    end
  end

end

class Routes::Test < TestCase
  def the_app
    app = Camping::Apps.select{|a| a.name == "Routes" }.first
    app.make_camp
    app
  end

  def test_backslash
    get '/'
    assert_body '/style.css'
  end

  # Test that we can get the actual controllers that we want.
  def test_controllers
    controllers = the_app::X.all
    assert controllers.count == 6, "how many controllers are there? #{controllers.count}"
  end

  def test_naked_controller
    controllers = the_app::X.all
    assert((controllers.include? "PageX" ), "PageX is not an included controller. #{controllers}")
    controller = the_app::X.const_get :PageX
    assert((controller.urls == ["/page/([^/]+)"]), "PageX Controller's Routes are not right. #{controller.urls}")
  end

  def test_inherited_controller_not_getting_its_parents_urls
    controller = the_app::X.const_get :Post
    assert_equal ["/post", "/post/post"], controller.urls, "Post Controller's urls are not right. #{controller.urls}"
    second_controller = the_app::X.const_get :Bump
    assert_equal ["/bump"], second_controller.urls, "Bump Controller's urls are not right. #{second_controller.urls}"
  end

  def test_routes_helper
    collection = Camping::Commands.routes((Camping::Apps.select{|a| a.name == "Routes" }.first), true)
    routes = collection.routes.map(&:to_s)
    assert_equal 10, routes.count, "Routes are not numbered correctly. #{routes}"
    assert (routes.include? "PageX: get: /page/([^/]+) - /page/:string"), "Routes do not include: [PageX: get: /page/([^/]+) - /page/:string], #{routes}"
    assert (routes.include? "PageX: post: /page/([^/]+) - /page/:string"), "Routes do not include: [PageX: post: /page/([^/]+) - /page/:string], #{routes}"
    assert (routes.include? "Index: get: / - /"), "Routes do not include: [Index: get: / - /], #{routes}"
  end

end
