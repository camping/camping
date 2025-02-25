require 'samovar'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class Serve < Samovar::Command
			self.description = "Runs a Camping server"
			
			options do
				option "-p/--port <number>", "Overrides the port number", type: Integer
				option "-h/--hostname <hostname>", "Specifies the hostname"
				option "-e/--environment <environmentk>", "Chooses the environment. Defaults to production."
			end
			
			def call
				server = Camping::Server.new
				if @options[:port]
					server
				else
				end
			end
			
			def serve
				container = Async::Container.new
				
				config_path = root + @options[:config]
			end

		end
	end
end
