# test/commands/test_new.rb
require_relative 'commands_helper'

class TestNewCommand < CampingFeatureHelper
	
	def test_new_project
		# already moving to the tmp directory		
		_, output = run_camping "new"
		assert_includes output, "NewCampingCalled"
	
		# move to the camp directory
		original_dir = Dir.pwd
		Dir.chdir "camp"

		# Build a list of all the files		
		files = files_in_directory
		folders = folders_in_directory
		hidden = hidden_files_in_directory
		
		assert files.include?('camp.rb'), "missing camp.rb"
		assert files.include?('Gemfile'), "missing Gemfile"
		assert files.include?('README.md'), "missing README.md"
		assert files.include?('Rakefile'), "missing Rakefile"
		assert files.include?('config.kdl'), "missing config.kdl"
		assert folders.include?('public'), "missing public folder."
		assert folders.include?('test'), "missing test folder."
		assert hidden.include?('.gitignore'), ".gitignore is missing."
		assert hidden.include?('.ruby-version'), ".ruby-version is missing."
		
		# move back out.
		Dir.chdir original_dir
	end
	
	# TODO: Finish this test after we decide on a good directory structure for Camping.
	# Generates expected directory Structure
	#
	# Camping has an expected directory structure:
	#
	#   .gitignore
	#   .ruby-version
	#   Gemfile
	#   Rakefile
	#   camp.rb
	#   config.kdl
	#   src/
	#   lib/
	#   public/
	#   test/
	#   apps/
	#
	# This test checks to make certain that the generator command creates this
	# directory structure.
	#def test_app_generates_directory_structure
	#	move_to_tmp
	#end
	
end
