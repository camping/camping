# Frank
#
# Frank is Camping gear that adds Sinatra style routing shortcuts to the Object
# namespace and to camping controllers themselves:
#
#    get '/' {
#      "Hello World"
#    }
#
# Calling the get method creates a controller, and in the event of no default
# app yet, creates an app named Frank.



# Extension to make sinatra style routes helper.
module Gear
	module FrankStyle

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
		def self.make_camping_route(method, routes, app=nil, &block)
			meth = method.to_s

			inf = caller.first.split(":")
			file_name, line_number = inf[0], inf[1]

			s = ""
			rs = ""
			routes.each do |r|
				if r == '/'
					r = 'Index'
				end
				rs += "'#{r}'" + ","
				r.split("/").each(&:capitalize!).each{|t|s<< t}
				# s << r
			end
			rs.chop!

			symbol = s.to_sym

			if Camping::Apps.count == 0
				# In the case of a naked sinatra style invokation
				Camping.goes :Frank
				m = Camping::Apps.first

			# else
			#   # In the case of invoking sinatra style in Camping App Module
			#   selected = Camping::Apps.select { |a| a.name == app }
			#   if selected.count > 0
			#     m = selected.first
			#   else
			#     raise "You're trying to make a route for an app that doesn't exist. App Name: #{app}. Apps: #{Camping::Apps}."
			#   end
			else
				m = app
			end

			# Controller name
			cname = "#{meth.capitalize}#{symbol.to_s}"

			begin
				m.module_eval(%Q[
				module Controllers
					class #{cname} < R #{rs}
					end
				end
				], file_name, line_number.to_i)
			rescue => error
				if error.message.include? "superclass mismatch for class"
					raise "You've probably tried to define the same route twice using the sinatra method. ['#{route}']"
				else
					raise error
				end
			end

			m::X.const_get("#{cname}").send(:define_method, meth) { |*args|
				res = block[@env]

				if res.class == Array
					# if we're forwarding a response
					status = res[0]
					body = res[2].flatten.first
					headers = res[1]
				else
					# if we have a great string that's returned instead.
					status = 200
					body = res
					headers = {"content-type": "text/html"}
				end
				r(status, body, headers)
			}

			return nil
		end

		module ClassMethods
			def get(*routes, &block)     FrankStyle.make_camping_route('get', routes, self, &block) end
			def put(*routes, &block)     FrankStyle.make_camping_route('put', routes, self, &block) end
			def post(*routes, &block)    FrankStyle.make_camping_route('post', routes, self, &block) end
			def delete(*routes, &block)  FrankStyle.make_camping_route('delete', routes, self, &block) end
			def head(*routes, &block)    FrankStyle.make_camping_route('head', routes, self, &block) end
			# def options(*routes, &block) FrankStyle.make_camping_route('options', routes, self, &block) end
			def patch(*routes, &block)   FrankStyle.make_camping_route('patch', routes, self, &block) end
			def link(*routes, &block)    FrankStyle.make_camping_route('link', routes, self, &block) end
			def unlink(*routes, &block)  FrankStyle.make_camping_route('unlink', routes, self, &block) end


			# Turns this App into a proc to be consumed by one of the block based route generators
			# An easy way to forward requests to an app.
			# a references self, that's then captured by the proc, which is a closure.
			# because it's a closure, and because it captures self, we can then call
			# this proc anywhere we want.
			#
			# the syntax: `a[e]` is an implicit call to the `#call` method. the brackets
			# are syntatic sugar to get this to work. The following code is equivalient:
			#
			#	 e = []
			#  a.call(e)
			#  a.(e)
			#  a[e]
			#
			# This code is defined in the FrankStyle Camping Gear. Specifically in it's
			# ClassMethods module. ClassMethods is then extended onto our Camping app,
			# Giving it the appearance of being a method of the module.
			def to_proc
				a=self
				proc{|e|
					a.call(e)
				}
			end

		end

		def self.included(mod)
			mod.extend(ClassMethods)
		end

		# required for compliance reasons
		def self.setup(app, *a, &block) end

	end
end

# class Object #:nodoc:
# 	def get(*routes, &block)     FrankStyle.make_camping_route('get', routes, nil, &block) end
# 	def put(*routes, &block)     FrankStyle.make_camping_route('put', routes, nil, &block) end
# 	def post(*routes, &block)    FrankStyle.make_camping_route('post', routes, nil, &block) end
# 	def delete(*routes, &block)  FrankStyle.make_camping_route('delete', routes, nil, &block) end
# 	def head(*routes, &block)    FrankStyle.make_camping_route('head', routes, nil, &block) end
# 	# def options(*routes, &block) FrankStyle.make_camping_route('options', routes, nil, &block) end
# 	def patch(*routes, &block)   FrankStyle.make_camping_route('patch', routes, nil, &block) end
# 	def link(*routes, &block)    FrankStyle.make_camping_route('link', routes, nil, &block) end
# 	def unlink(*routes, &block)  FrankStyle.make_camping_route('unlink', routes, nil, &block) end
# end
