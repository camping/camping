module Camping
  module CommandsHelpers
    class RoutesParser

      def self.parse(app, silent)
        new(app).parse silent
      end

      def initialize(app)
        @parent_app, @routes = app, []
      end

      def url_from_name(controller_name, params)

        # We have to figure out the route from the Controller name
        splitty = controller_name.split(/(?<=\p{Ll})(?=\p{Lu})|(?<=\p{Lu})(?=\p{Lu}\p{Ll})/)
        url, it = "", 0
        splitty.each { |sis|
          if sis != "X" && sis != "N"
            url += "/#{sis.downcase}"
          else
            if params[it] == nil
              if sis == "N"
                url += "/:Integer"
              elsif sis == "X"
                url += "/:String"
              else
                url += "/#{sis}"
              end
            else
              url += "/:#{params[it]}"
            end
            it += 1
          end
        }
        url
      end

      def makeRoutes(controllers, controller, prefix = "", appname = "", routes = nil)
        contr_const, mappedURLS = controllers.const_get(controller), []

        (contr_const.instance_methods false).each { |http_method|

          # Parse named parameters from the method names
          params = contr_const.instance_method(http_method).parameters.map(&:last).map(&:to_s)

          if routes == nil
            url = url_from_name(controller.name, params)
            url = prefix + url if !prefix.empty?
            # puts "#{http_method.upcase} - prefix: #{prefix}, url: #{url}"
            mappedURLS.append Route.new(http_method, controller.name, appname, url)
          else
            # We have a list of routes that we need to match to methods now.
            routes.each { |route|
              url = url_from_name(controller.name, params)
              url = prefix + route if !prefix.empty?
              # puts "#{http_method.upcase} - prefix: #{prefix}, url: #{url}"
              mappedURLS.append Route.new(http_method, controller.name, appname, url)
            }
          end
        }
        mappedURLS
      end

      # Route Struct, for making and formatting a route.
      Route = Struct.new(:http_method, :controller, :app, :url)
      class Route

        def to_s
          "#{controller} #{normy(http_method)} " + "#{url}"
        end

        # pad the controller name to be the right length, if we can.
        def padded_message(appNameWidth, width)
          "#{"".ljust(appNameWidth, " ")}#{controller.ljust(width, " ")} #{normy(http_method)} " + "#{url}"
        end

        protected

        def normy(themethod)
          case themethod.to_s
          when "post"
            "POST    "
          when "put"
            "PUT     "
          when "patch"
            "PATCH   "
          when "delete"
            "DELETE  "
          else
            "GET     "
          end
        end

      end

      def parse(silent)
        it = 0; routes = []; apps = []

        if @parent_app.name == "Camping"
          apps = @parent_app::Apps
        else
          apps.append @parent_app
        end

        # Iterate over each app
        apps.each { |app|

          prefix = ""; prefix = "/#{app.name.downcase}" unless it == 0
          appname = app.name.downcase

          #Iterate over each controller
          app::X.constants.each { |controller|

            contr_const = app::X.const_get(controller)

            if (contr_const.respond_to? :urls) && !(contr_const.send :urls).empty?
              urls = contr_const.send :urls
              routes << makeRoutes(app::X, controller, prefix, appname, urls)
            else
              routes << makeRoutes(app::X, controller, prefix, appname)
            end
          }

          it += 1
        }

        routes.flatten!

        appNameWidth, width, appNames = 0, 0, []
        routes.each { |r|
          width = r.controller.length + 3 if r.controller.length > width
          appNameWidth = r.app.length + 3 if r.app.length > appNameWidth
        }
        if silent != true
          puts "#{"App".ljust(appNameWidth, " ")}#{"Controller".ljust(width, " ")} VERB     Route"
          routes.each {|r|
            if !appNames.include? r.app
              puts "--------------------------------------"
              puts "#{r.app.ljust(appNameWidth, " ")}".capitalize
              appNames << r.app
            end
            puts r.padded_message(appNameWidth, width)
          }
        end
        routes
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
    def self.routes(theApp = Camping, silent = false)
      Camping::CommandsHelpers::RoutesParser.parse theApp, silent
    end

  end
end
