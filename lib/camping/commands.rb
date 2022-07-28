module Camping
  module CommandsHelpers

    RouteCollection = Struct.new(:routes)
    class RouteCollection
      # Displays formatted routes from a route collection
      # Assumes that Route structs are stored in :routes.
      def display
        current_app, current_method = "", ""
        puts "App      VERB     Route"
        routes.each { |r|
          if current_app != r.app.to_s
            current_app = r.app.to_s
            current_method = ""
            puts "-----------------------------------"
            puts r.app_header
          end
          puts r.padded_message true
        }
      end

    end

    # Route Struct, for making and formatting a route.
    Route = Struct.new(:http_method, :controller, :app, :url)
    class Route

      def to_s
        "#{http_method}: #{url}"
      end

      # pad the controller name to be the right length, if we can.
      def padded_message(with_method = false)
        "#{pad}#{(with_method ? http_method.to_s.upcase.ljust(pad.length, " ") : pad)}#{replace_reg url}"
      end

      def app_header
        "#{app.to_s}"
      end

      def controller_header
        "#{pad}#{app.to_s}::#{controller.to_s}"
      end

      protected

      def http_methods
        ["get", "post", "put", "patch", "delete"]
      end

      def replace_reg(pattern = "")
        xstr = "([^/]+)"; nstr = "(\d+)"
        pattern = pattern.gsub(xstr, ":string").gsub("(\\d+)", ":integer") unless pattern == "/"
        pattern
      end

      def pad
        "         "
      end

    end

    class RoutesParser
      def self.parse(app)
        new(app).parse
      end

      def initialize(app = Camping)
        @parent_app, @routes = app, []
      end

      def parse
        @parent_app.routes
        collected_routes = []

        make_routes =  -> (a) {
          a::X.constants.map { |c|
            k = a::X.const_get(c)
            im = k.instance_methods(false).map!(&:to_s)
            methods = im & ["get", "post", "put", "patch", "delete"]
            if k.respond_to?:urls
              methods.each { |m|
                k.urls.each { |u|
                  collected_routes.append Camping::CommandsHelpers::Route.new(m,c,a.to_s,u)
                }
              }
            end
          }
        }

        if @parent_app == Camping
          @parent_app::Apps.each {|a|
            make_routes.(a)
          }
        else
          make_routes.(@parent_app)
        end

        routes_collection = Camping::CommandsHelpers::RouteCollection.new(collected_routes)
      end
    end

  end

  class Commands

    # A helper method to spit out Routes for an application
    def self.routes(theApp = Camping, silent = false)
      routes = Camping::CommandsHelpers::RoutesParser.parse theApp
      routes.display unless silent == true
      return routes
    end

  end
end
