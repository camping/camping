require_relative 'command/default'

module Camping
	module Command
		def self.call(*args)
			Default.call(*args)
		end
	end
end
