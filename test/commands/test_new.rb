# test/commands/test_new.rb
require_relative 'commands_helper'

class TestNewCommand < CampingFeatureHelper
	
	def test_new
		_, output = run_camping "new"
		assert_includes output, "Camping v#{Camping::VERSION}"
	end
	
	#def test_version
	#	_, output = run_camping "-v"
	#	assert_includes output, "Camping v#{Camping::VERSION}"
	#	_, output = run_camping "--version"
	#	assert_includes output, "Camping v#{Camping::VERSION}"
	#end
	#
	#def test_help
	#	_, output = run_camping "-?"
	#	assert_includes output, "CAMPING! miniature rails for anyone"
	#	assert_includes output, "Run Camping"
	#	assert_includes output, "Display Camping's routes"
	#	
	#	_, output = run_camping "--help"
	#	assert_includes output, "CAMPING! miniature rails for anyone"
	#	assert_includes output, "Run Camping"
	#	assert_includes output, "Display Camping's routes"		
	#end
	
end
