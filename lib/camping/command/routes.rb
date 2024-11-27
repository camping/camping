require 'samovar'

require 'camping/server'
require 'camping/tools'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class Routes < Samovar::Command
			self.description = "Display Camping's routes"
			
			options do
				#option "-r/--routes", "Lists the Routes"
				option '-a/--app <text>', "puts the routes for the specified app."
				option '-s/--silent', "Don't display the routes for some reason."
			end
			
			def call
				server = Camping::Server.new
				silent = false
				silent = true if @options[:silent]
				
				if @options[:app]
					routes(@options[:app], silent)
				else
					routes(Camping, silent)
				end
			end
			
			# A helper method to spit out Routes for an application
			def routes(theApp = Camping, silent = false)
				#names = ::CampTools.app_name_from_input(theApp) 
				if theApp.is_a? String
					::CampTools.app_name_from_input(theApp) => {app_name:, snake_name:, camel_name:}
				else
					app_name = theApp
				end
				
				rrs = Parser.parse app_name
				rrs.display unless silent == true
				return rrs
			end
			
			class Parser
				def self.parse(app) = new(app).parse
			
				def initialize(app = Camping)
					app = Object.const_get app if app != Camping
					@parent_app, @routes = app, []
				end
			
				def parse
					@parent_app.make_camp
					collected_routes = []
			
					make_routes = -> (a) {
			
						a::X.all.map {|c|
							k = a::X.const_get(c)
							im = k.instance_methods(false).map!(&:to_s)
							methods = im & ["get", "post", "put", "patch", "delete"]
							if k.respond_to?:urls
								methods.each { |m|
									k.urls.each { |u|
										collected_routes.append Routes::Route.new(m,c,a.to_s,u)
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
			
					Routes::Collection.new(collected_routes)
				end
			end
			
			# Route Struct, for making and formatting a route.
			Route = Struct.new(:http_method, :controller, :app, :url)
			class Route
			
				def to_s
					"#{controller}: #{http_method}: #{url} - #{replace_reg url}"
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
					xstr = "([^/]+)";
					pattern = pattern.gsub(xstr, ":string").gsub("(\\d+)", ":integer") unless pattern == "/"
					pattern
				end
			
				def pad
					"         "
				end
			
			end
			
			Collection = Struct.new(:routes)
			class Collection
				# Displays formatted routes from a route collection
				# Assumes that Route structs are stored in :routes.
				def display
					current_app, current_controller = "", ""
					puts "App      VERB     Route"
					routes.each { |r|
						if current_app != r.app.to_s
							current_app = r.app.to_s
							puts "-----------------------------------"
							puts r.app_header
						end
						if current_controller != r.controller.to_s
							current_controller = r.controller.to_s
							puts r.controller_header
						end
						puts r.padded_message true
					}
				end
			
			end
			
		end
	end
end
