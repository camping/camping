require 'samovar'

require 'camping/server'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class NewCamping < Samovar::Command
			self.description = "Display Camping's routes"
			
			def call
				puts "put camping new command stuff here."
			end
		end
	end
end
