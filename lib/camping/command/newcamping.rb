require 'samovar'

require 'camping/server'
require 'camping/generators/project'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class NewCamping < Samovar::Command
			self.description = "Display Camping's routes"
			
			options do
				option '-a/--app <text>', "The name your app, can be camel cased"
			end
			
			def call
				puts "NewCampingCalled"
				if @options[:app]
					Camping::Generators::Project.call(@options[:app])
				else
					Camping::Generators::Project.call()
				end
			end
		end
	end
end
