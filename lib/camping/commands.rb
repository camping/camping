module Camping
  module CommandsHelpers

    RouteCollection = Struct.new(:routes)
    class RouteCollection
      # Displays formatted routes from a route collection
      # Assumes that Route structs are stored in :routes.
      def display
        current_app, current_method = "", ""
        routes.each { |r|
          # puts r
          if current_app != r.app.to_s
            puts ""
            current_app = r.app.to_s
            current_method = ""
            puts r.app_header
            puts "-----------------------------------"
          end
          if current_method != r.http_method.to_s
            current_method = r.http_method.to_s
            puts r.padded_message true
          else
            puts r.padded_message
          end
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
        with_method ? "#{http_method.to_s.upcase.ljust(10, " ") } " + "#{url}" : "           " + "#{url}"
      end

      def app_header
        "#{app.to_s}"
      end

      def controller_header
        "           #{app.to_s}::#{controller.to_s}"
      end

      protected

      def http_methods
        ["get", "post", "put", "patch", "delete"]
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

#       # takes a route string, which is regex and converts it to the defined Class in the App.
#       def reverse_regex(pattern)
#         nstr = "(\d+)"
#         xstr = "([^/]+)"
#
#         if pattern == "/"
#           "Index"
#         else
#           newpattern = ""
#           (pattern.gsub("([^/]+)", "X").gsub("(\d+)", "N").split('/').each { |str| str.capitalize! }).each {|str| newpattern += str}
#           newpattern
#         end
#
#       end

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
