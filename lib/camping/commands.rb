module Camping
  module CommandsHelpers
    class RoutesParser

      def self.parse(app)
        new(app).parse
      end

      def initialize(app)
        @parent_app = app
        @routes = []
      end

      def normy(themethod)
        case themethod.to_s
        when "post"
          "POST  "
        when "put"
          "PUT   "
        when "patch"
          "PATCH "
        when "delete"
          "DELETE"
        else
          "GET   "
        end
      end

      def makeRoutes(controllers, controller)

        contr_const = controllers.const_get(controller)

        # gets the http methods from the list of instance methods
        http_methods = contr_const.instance_methods false
        class_methods = contr_const.methods false

        mappedURLS = []

        http_methods.each { |http_method|
          # Gets the list of params
          named_parameters = contr_const.instance_method(http_method).parameters.map(&:last).map(&:to_s)

          # Craft the URL
          splitty = controller.name.split(/(?<=\p{Ll})(?=\p{Lu})|(?<=\p{Lu})(?=\p{Lu}\p{Ll})/)

          mappedurl = ""; parameteriteration = 0
          splitty.each { |sis|
            if sis != "X" && sis != "N"
              mappedurl += "/#{sis.downcase}"
            else
              if named_parameters[parameteriteration] == nil
                if sis == "N"
                  mappedurl += "/:Integer"
                elsif sis == "X"
                  mappedurl += "/:String"
                else
                  puts "{sis}"
                  mappedurl += "/#{sis}"
                end
              else
                mappedurl += "/:#{named_parameters[parameteriteration]}"
              end
              parameteriteration += 1
            end
          }
          mappedurl += "/"

          # puts mappedurl
          # puts "#{controller} - #{mappedurl}"
          # message = "#{(normy(http_method))} - #{mappedurl}"
          route = Route.new(http_method, controller.name, "App", mappedurl)

          # puts route

          mappedURLS.append route
        }
        mappedURLS
      end

      # Route Struct, for making and formatting a route from underlying data.
      Route = Struct.new(:http_method, :controller, :app, :url)
      class Route

        # The width of the controller name
        def width; @width ||= 0; end
        def width=(value); @width = value; end

        # The Actual controller name
        def controller_name; @controller_name ||= ""; end
        def controller_name=(value); @controller_name = value; end

        # The Actual controller name
        def the_url; @the_url ||= ""; end
        def the_url=(value); @the_url = value; end

        def message
          pad
          "#{controller_name} #{normy(http_method)} "
          "/#{app.name.downcase}#{self.reverse_regex(route)}"
        end

        protected

        # pad the controller name to be the right length, if we can.
        def pad
          if controller.length < width
            @controller_name = @controller_name.ljust(width, " ")
          end
        end

        def normy(themethod)
          case themethod.to_s
          when "post"
            "POST  "
          when "put"
            "PUT   "
          when "patch"
            "PATCH "
          when "delete"
            "DELETE"
          else
            "GET   "
          end
        end

      end

      def parse
        it = 0; routes = []
        @parent_app::Apps.each { |app|
          # puts app.name
          if it == 0
            app::X.constants.each { |controller|
              contr_const = app::X.const_get(controller)

              if (contr_const.respond_to? :urls) && !(contr_const.send :urls).empty?
                # puts controller
                puts "  urls:"
                urls = contr_const.send :urls

                urls.each { |url|
                  puts url
                }
                routes.append(makeRoutes(app::X, controller)).flatten

              else
                routes.append(makeRoutes(app::X, controller)).flatten
                puts routes
              end
              # puts " "
              # return (k.method_defined?(m)) ?
              # if contr_const.responds_to
              #   c.respond_to? :urls

              # puts contr_const.method_defined? :urls
            }
          else
            app.routes.each { |route|
              puts "  /#{app.name.downcase}#{self.reverse_regex(route)}"
            }
          end
          it += 1
        }
      end

      # takes a route string, which is regex and converts it to the defined Class in the App.
      def reverse_regex(pattern)
        nstr = "(\d+)"
        xstr = "([^/]+)"

        if pattern == "/"
          "Index"
        else
          newpattern = ""
          (pattern.gsub("([^/]+)", "X").gsub("(\d+)", "N").split('/').each { |str| str.capitalize! }).each {|str| newpattern += str}
          newpattern
        end

      end

    end

  end


  class Commands

    # A helper method to spit out Routes for an application
    def self.routes()
      # get all the routes?
      # Camping::Apps[0]::Controllers.constants
      # (Camping::Apps[0]::X.const_get :Pages).instance_methods false
      Camping::CommandsHelpers::RoutesParser.parse(Camping)
    end

  end
end
