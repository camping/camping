require 'samovar'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class Routes < Samovar::Command
			self.description = "Displays camping's routes"
			
			#options do
			#	option "-p/--port <number>", "Overrides the port number", type: Integer
			#end
			
			def call
				puts "put camping routes stuff here."
			end
		end
	end
end
