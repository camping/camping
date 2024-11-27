# test/commands/test_routes.rb
require_relative 'commands_helper'

# Tests's the routes command: camping -r/ camping --routes


class TestRoutesCommand < CampingFeatureHelper
	
	def before_all
		create_directory "_routes"
		create_file "_routes/camp.rb", <<~CAMP
		require 'camping'
		
		Camping.goes :Nuts
		
		get "/" do
		"Hello Friends"
		end
		
		get "/accounts" do
		"Get Some Accounts"
		end
		
		get "/accounts/new" do
		"Try my hardest."
		end
		
		get "/home", "/about" do
		"About page"
		end
		
		CAMP
		
	end
	
	def after_all
		trash_config()
	end
	
	def test_routes
		#puts Dir.pwd
		run_camping "routes"
	end
	
	
	#argv = Camping::Command::ARGV = []
	#define_method(:argv) { argv }
	
	#describe Camping::Command do 
		
		#before do
		#	create_directory "_routes"
		#end
		#
		#def create_file(*args)
		#	puts "This should work"
		#end
		
		#describe "When we're running commands" do
		#	it "display a simple routes output" do
		#		create_file "_routes/camp.rb", <<~CAMP
		#		require 'camping'
		#		
		#		Camping.goes :Nuts
		#		
		#		get "/" do
		#		"Hello Friends"
		#		end
		#		
		#		get "/accounts" do
		#		"Get Some Accounts"
		#		end
		#		
		#		get "/accounts/new" do
		#		"Try my hardest."
		#		end
		#		
		#		get "/home", "/about" do
		#		"About page"
		#		end
		#		
		#		CAMP
		#	end
		#end
		
		#def after_all
		#
		#end
	
	#end
end

#
#describe Camping::Command do
#	
# 
#	
# 
#end

