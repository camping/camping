require 'test_helper'
require 'camping'

Camping.goes :Goesmeta

class Goesmeta::Test < TestCase

	def test_meta_data
		meta = value = Goesmeta._meta
		value = "nil" if meta == nil
		assert meta != nil, "meta data was not added. #{value}"
		assert meta[:location][:file] == "/Users/kow/code/camping/camping/test/app_goes_meta.rb", "Wait a minute. This app Goesmeta, has a wonky creation location."
		assert meta[:location][:line_number] == 4, "App creation location line number is wrong. It's supposed to be 4."
	end

	def test_has_keys_set
		assert Goesmeta.options.has_key?(:_app_name), "app name was not set in Camping.goes. #{Goesmeta.options}"
		assert Goesmeta.options.has_key?(:_parent_app), "parent app was not set in Camping.goes. #{Goesmeta.options}"
	end

end
