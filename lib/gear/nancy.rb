module Gear

	# Nancy
	#
	# Nancy is Camping gear that adds Sinatra style routing shortcuts to the Object
	# namespace and to camping controllers themselves:
	#
	#    get '/' {
	#      "Hello World"
	#    }
	#
	# Calling the get method creates a controller, and in the event of no default
	# app yet, creates an app named Frank.
	module Nancy

		class << self

			# normalizes the routes provided to the controller, then returns some variables
			# used in make_camping_route
			def normalize_routes(routes)
				s = ""
				rs = ""
				routes.each do |r|
					rs += "'#{r}'" + ","
					if r == '/'
						r = 'Index'
					end
					r.split("/").each(&:capitalize!).each{|t|
						s << t.gsub(/[^a-z0-9A-Z ]/, '')
					}
				end
				rs.chop!

				symbol = s.to_sym
				{rs: rs, symbol: symbol}
			end

			# ensures an app exists for the controllers.
			def ensure_app(app)
				if Camping::Apps.count == 0
					# In the case of a naked sinatra style invokation
					Camping.goes :Frank
					m = Camping::Apps.first
				else
					m = app
				end
				m
			end

			# Make a camping route provided with a method type, a route, an optional app, and
			# a required block:
			#
			#   get '/another/thing' do
			#     render :another_view
			#   end
			#
			# Calling the shorthand make route helper methods inside of an app module, adds
			# The route to that App. If you don't have any apps yet, then an app named Frank
			# will be made for you.
			def make_camping_route(method, routes, app=nil, &block)

				inf = caller.first.split(":")
				file_name, line_number = inf[0], inf[1]

				meth = method.to_s

				self.normalize_routes(routes) => {rs:, symbol:}

				m = self.ensure_app app

				# Controller name
				cname = "#{meth.capitalize}#{symbol.to_s}"

				begin

					# Find out which eval script to use.
					eval_script = m.name.include?("Controllers") ? controller_script(name: cname,routes: rs) : module_script(name: cname,routes: rs)

					m.module_eval(eval_script, file_name, line_number.to_i)
				rescue => error
					if error.message.include? "superclass mismatch for class"
						raise "You've probably tried to define the same route twice using the sinatra method. ['#{rs}']"
					else
						raise error
					end
				end

				# This is an interesting block. At times we'll pass an App to a route
				# which will implicitly call it's `to_proc` method. In those cases, it's
				# that block that is set as the block here, and it returns a Rack response.
				# If we have a rack response instead of string, then we need to extract
				# the response then reassign the values. the r method  is a great helper
				# for that.
				constantine = m.name.include?("Controllers") ? m.const_get("#{cname}") : m::X.const_get("#{cname}")

				if block.arity == -1
					constantine.send(:define_method, meth) { |*args|
						block[*args]
					}
				elsif block.arity == 1
					constantine.send(:define_method, meth) {
						res = block[@env] # if we're forwarding a response
						status = res[0]
						headers = res[1]
						body = res[2].flatten.first
						r(status, body, headers)
					}
				else # assuming arity is 0
					constantine.send(:define_method, meth) {
						block[]
					}
				end

				return nil
			end

			# returns a formatted string for making a controller class in the App module
			def module_script(name:, routes:)
				%Q[
				module Controllers
					class #{name} < R #{routes}
					end
				end
				]
			end

			# returns a formatted string for making a controller class in the Controllers module
			def controller_script(name:, routes:)
				%Q[
					class #{name} < R #{routes}
					end
				]
			end

			def included(mod)
				mod.extend(ClassMethods)
				mod::Controllers.extend(ClassMethods)
			end

			# required for compliance reasons
			def setup(app, *a, &block) end

		end

		module ClassMethods

			# Helper methods added to your Camping app that facilitates
			def get(*routes, &block)     Nancy.make_camping_route('get', routes, self, &block) end
			def put(*routes, &block)     Nancy.make_camping_route('put', routes, self, &block) end
			def post(*routes, &block)    Nancy.make_camping_route('post', routes, self, &block) end
			def delete(*routes, &block)  Nancy.make_camping_route('delete', routes, self, &block) end
			def head(*routes, &block)    Nancy.make_camping_route('head', routes, self, &block) end
			def patch(*routes, &block)   Nancy.make_camping_route('patch', routes, self, &block) end
			def link(*routes, &block)    Nancy.make_camping_route('link', routes, self, &block) end
			def unlink(*routes, &block)  Nancy.make_camping_route('unlink', routes, self, &block) end

			# Turns this App into a proc to be consumed by one of the block based route generators
			# An easy way to forward requests to an app.
			# a references self, that's then captured by the proc, which is a closure.
			# because it's a closure, and because it captures self, we can then call
			# this proc anywhere we want.
			#
			# The syntax: `a[e]` is an implicit call to the `#call` method. the brackets
			# are syntatic sugar to get this to work. The following code is equivalent:
			#
			#	 e = [] # given e is a rack array.
			#  a.call(e)
			#  a.(e)
			#  a[e]
			#
			# This code is defined in the Nancy Camping Gear. Specifically in it's
			# ClassMethods module. ClassMethods is then extended onto our Camping app,
			# Giving it the appearance of being a method of the module. In our cases
			# Our modules are our Apps.
			# The code:
			#
			#   def to_proc = method(:call).to_proc
			#
			# First gets a `Method` object from the app, then converts it to a proc.
			# In our case we just want call, so this makes the whole api pretty simple.
			# def to_proc = method(:call).to_proc
			def to_proc = method(:call).to_proc

		end

	end
end
