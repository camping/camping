require 'test_helper'
require 'camping'
require 'camping/commands'
require 'rack'

# nuke all the apps

Camping.goes :Frank
Frank.use Rack::Lint

module Frank
	get "/" do
		"Hello Friends"
	end

	get "/accounts" do
		"Get Some Accounts"
	end

	get '/account/(\d+)' do |*a|
		"Get Some Account numbered #{a.first}"
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

	# Test Controllers too
	module Controllers
		get "/even_more" do
			"Hello Friends"
		end
	end

end

Camping.goes :Bill

module Bill::Controllers
	class Friends
		def get
			"It looks like you have lots of friends."
		end
	end
end

module Frank
	get '/friends', &Bill
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
		assert (controllers.count == 13), "There are not the right number of controllers: #{controllers.count}."
	end

	def test_controller_names
		controllers = the_controllers
		assert controllers.include?(:GetIndex), "Not Found: :GetIndex. Controllers: #{controllers}."
		assert controllers.include?(:GetAccounts), "Not Found: :GetAccounts. Controllers: #{controllers}."
		assert controllers.include?(:GetAccountd), "Not Found: :GetAccount. Controllers: #{controllers}."
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
		get '/account/15'
		assert_body "Get Some Account numbered 15", "Body is not what we expect."
	end

	def test_to_proc_works_for_apps
		get '/friends/'
		assert_body "It looks like you have lots of friends.", "Well this is a bummer. Frank is left out, and not called."
	end

	def test_that_using_nancy_in_a_controller_works
		get '/even_more'
		assert_body 'Hello Friends'
	end

	# TODO: Test that we are returning proper headers, that are not symbols, When Nancying.
	def test_that_header_keys_aint_symbols

	end

end
