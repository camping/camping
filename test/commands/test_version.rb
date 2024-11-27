# test/commands/test_routes.rb
require_relative 'commands_helper'

# Tests's the routes command: camping -r/ camping --routes


class TestRoutesCommand < CampingFeatureHelper
	
	def test_version
		_, output = run_camping "-v"
		assert_includes output, "Camping v#{Camping::VERSION}"
		_, output = run_camping "--version"
		assert_includes output, "Camping v#{Camping::VERSION}"
	end
	
end
