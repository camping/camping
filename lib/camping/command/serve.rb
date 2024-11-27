require 'samovar'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class Serve < Samovar::Command
			self.description = "Run Camping"
			
			options do
				option "-p/--port <number>", "Overrides the port number", type: Integer
				option "-h/--hostname <hostname>", "Specifies the hostname"
			end
			
			def call
				puts "Put camping run server stuff here."
			end
		end
	end
end
