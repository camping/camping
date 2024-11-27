# test/commands/test_routes.rb
require_relative 'commands_helper'

# Tests's the routes command: camping -r/ camping --routes

class TestRoutesCommand < CampingFeatureHelper
	
	def before_all
		super
		create_file "camp.rb", <<~CAMP
		require 'camping'
		
		Camping.goes :Nuts
		
		module Nuts
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
		end
		
		Camping.goes :Hard
		module Hard
			get "hard/accounts" do
				"Get Some Accounts"
			end
			
			get "hard/accounts/new" do
				"Try my hardest."
			end
		end
		
		CAMP
		
	end
	
	def test_routes
		_, output = run_camping "routes"
		assert_includes output, "Nuts::GetHomeAbout"
		assert_includes output, "Hard::GetHardAccounts"
		
		_, output = run_camping "routes", "-a Nuts"
		assert_includes output, "App      VERB     Route"
		assert_includes output, "GET      /accounts/new"
		refute_includes output, "Hard::GetHardAccounts"
	end
	
end
