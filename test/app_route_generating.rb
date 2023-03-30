require 'test_helper'
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

  class PageX < R Camper
    def get
    end

    def post
    end
  end

  class Edit < R Camper
    def get
    end

    def post
    end
  end

  class Post < R Edit
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
    collection = Camping::Commands.routes((Camping::Apps.select{|a| a.name == "Routes" }.first), true)
    routes = collection.routes.map(&:to_s)
    assert_equal 5, routes.count, "Routes are not numbered correctly. #{routes}"
    assert (routes.include? "get: /page/([^/]+)"), "Routes do not include: [get: /page/([^/]+) - /page/:string], #{routes}"
    assert (routes.include? "post: /page/([^/]+)"), "Routes do not include: [post: /page/([^/]+) - /page/:string], #{routes}"
    assert (routes.include? "get: / - /"), "Routes do not include: [get: / - /], #{routes}"
  end

  def the_app
    Camping::Apps.select{|a| a.name == "Routes" }.first
  end

  def test_new_routes
    app = the_app
    assert (app::RS.length == 10), "Routes aint doing well. The RS array is empty."
  end

#   def test_controller_inheritance
#     app = the_app
#
#     # app::Controllers.constants.each do |c|
#     #   puts "#{c.name}" unless c.name == 'Camper' || c.name == 'I'
#     # end
#     collection = Camping::Commands.routes((Camping::Apps.select{|a| a.name == "Routes" }.first), true)
#     routes = collection.routes.map(&:to_s)
#
#     puts ""
#     puts routes
#     assert_equal routes.count, 5, "Routes are not numbered correctly."
#   end
end
