require 'samovar'

require 'camping/server'
require 'camping/generators/new'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		class NewCamping < Samovar::Command
			self.description = "Display Camping's routes"
			
			options do
				option '-a/--app <text>', "The name your app, can be camel cased"
			end
			
			def call
				if @options[:app]
					Camping::Generators::New(@options[:app])
				else
					Camping::Generators::New()
				end
			end
		end
	end
end
