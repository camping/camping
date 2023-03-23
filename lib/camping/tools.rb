# frozen_string_literal: true

# Camping Tools is a toolbox for Camping
module Camping
	module Tools
		class << self
			def to_snake(string)
				string = string.to_s if string.class == Symbol
				string.gsub(/::/, '/').
				gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
				gsub(/([a-z\d])([A-Z])/,'\1_\2').
				tr("-", "_").
				downcase
			end
		end
	end
end
