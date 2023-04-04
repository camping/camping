require 'test_helper'
require 'camping'
require 'camping/commands'

# nuke all the apps

Camping.goes :Frank

module Frank
	get "/" do
		"Hello Friends"
	end

	get "/accounts" do
		"Get Some Accounts"
	end

	post "/accounts/new" do
		"Try my hardest."
	end

	get "/home", "/about" do
		"About page"
	end

	put "/it/all/out/there" do
		"It's all out there now."
	end

	delete '/this/stuff/' do
		"Everything will be deleted"
	end

	head '/get/ahead' do
		"The very best you can do"
	end

	patch '/this/boat' do
		"Row Row Row your boat"
	end

	link '/to/the/past' do
		"Link! He come to town! come to save! The princess Zelda!"
	end

	unlink '/game/over' do
		"start over?"
	end

end


Camping.goes :Nancy

module Nancy::Controllers
	class Friends
		def get
			"It looks like you have lots of friends."
		end
	end
end

module Frank
	get '/friends', &Nancy
end


class Frank::Test < TestCase

	def the_app
		Camping::Apps.select{|a| a.name == "Frank" }.first
	end

	def the_controllers
		app = the_app
		app::X.constants.filter { |el|
			con = el.to_s
			con != 'I' && con != 'Camper'
		}
	end

	def test_number_of_controllers
		controllers = the_controllers
		assert (controllers.count == 11), "There are not the right number of controllers: #{controllers.count}."
	end

	def test_controller_names
		controllers = the_controllers
		assert controllers.include?(:GetIndex), "Not Found: :GetIndex. Controllers: #{controllers}."
		assert controllers.include?(:GetAccounts), "Not Found: :GetAccounts. Controllers: #{controllers}."
		assert controllers.include?(:PostAccountsNew), "Not Found: :PostAccountsNew. Controllers: #{controllers}."
		assert controllers.include?(:GetHomeAbout), "Not Found: :GetHomeAbout. Controllers: #{controllers}."
		assert controllers.include?(:PutItAllOutThere), "Not Found: :PutItAllOutThere. Controllers: #{controllers}."
		assert controllers.include?(:DeleteThisStuff), "Not Found: :DeleteThisStuff. Controllers: #{controllers}."

		assert controllers.include?(:HeadGetAhead), "Not Found: :HeadGetAhead. Controllers: #{controllers}."
		# assert controllers.include?(:OptionsAllTheOptions), "Not Found: :OptionsAllTheOptions. Controllers: #{controllers}."
		assert controllers.include?(:PatchThisBoat), "Not Found: :PatchThisBoat. Controllers: #{controllers}."
		assert controllers.include?(:LinkToThePast), "Not Found: :LinkToThePast. Controllers: #{controllers}."
		assert controllers.include?(:UnlinkGameOver), "Not Found: :UnlinkGameOver. Controllers: #{controllers}."

	end

	def test_get_works_for_controllers
		get '/accounts/'
		assert_body "Get Some Accounts", "Body is not what we expect."
	end

	def test_blocks_take_arguments

	end

	def test_to_proc_works_for_apps
		get '/friends/'
		# puts last_response.to_a
		# assert_equal "It looks like you have lots of friends.", response_body, "Well this is a bummer. Nancy is left out, and not called. #{response_body}"
		assert_body "It looks like you have lots of friends.", "Well this is a bummer. Nancy is left out, and not called."
	end

end
