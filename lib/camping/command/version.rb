require 'samovar'

module Camping
	module Command
		class Version < Samovar::Command
			self.description = "Displays Camping's current version: v#{Camping.version}"
			def call = puts "Camping v#{Camping.version}"
		end
	end
end
