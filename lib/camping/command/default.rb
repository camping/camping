require_relative 'serve'
require_relative 'routes'
require_relative 'newcamping'
#require_relative 'generate'
require_relative '../version'

require 'samovar'

module Camping
	module Command
	
		# The default command is called, creatively, Default
		# without given options, it tries to start a development server
		# It also processes other options.
		class Default < Samovar::Command
			self.description = "CAMPING! miniature rails for anyone"
			
			# default options.
			options do
				option "-?/--help", "Display a help message"
				option "-v/--version", "Displays the current version"
				option "-h/--host", "Host for web server to bind to (default is all IPs)"
				option "-p/--port", "Port for web server (defaults to 3301)"
			end
			
			# nested commands that we grab from the second parameter
			nested :command, {
				"serve" => Serve,
				"console" => Console,
				"routes" => Routes,
				"new" => NewCamping,
				#"version" => Version,
			}, default: "serve"
			
			# call()
			# parses input and instantiates a new Default object, then calls this
			# method
			def call
				
				if @options[:version]
					puts "Camping v#{Camping::VERSION}"
				elsif @options[:help]
					puts "You need some serious help"
				else
					# @command is mapped to a nested command from above If a command is
					# given.
					@command.call
				end
				
			end
			
		end
	end
end
