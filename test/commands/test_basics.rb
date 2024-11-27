# test/commands/test_routes.rb
require_relative 'commands_helper'

# Tests's the routes command: camping -r/ camping --routes

class TestBasicsCommand < CampingFeatureHelper
	
	def test_version
		_, output = run_camping "-v"
		assert_includes output, "Camping v#{Camping::VERSION}"
		_, output = run_camping "--version"
		assert_includes output, "Camping v#{Camping::VERSION}"
	end
	
	def test_help
		_, output = run_camping "-h"
		assert_includes output, "CAMPING! miniature rails for anyone"
		assert_includes output, "Run Camping"
		assert_includes output, "Displays camping's routes"
	end
	
end
