require 'helper'
require 'camping'

Camping.goes :Goesmeta

class Goesmeta::Test < TestCase

	def test_meta_data
		options = Goesmeta.options
		meta = value = options[:_meta]
		value = "nil" if meta == nil
		assert meta != nil, "meta data was not added. #{value}"
		assert meta[:file].include?("/test/app_goes_meta.rb"), "Wait a minute. This app Goesmeta, has a wonky creation location. #{meta[:file]}"
		assert meta[:line_number] == 4, "App creation location line number is wrong. It's supposed to be 4."
	end

	def test_has_keys_set
		opt = Goesmeta.options[:_meta]
		assert opt.has_key?(:file), "app file was not set in Camping.goes. #{opt}"
		assert opt.has_key?(:parent), "parent app was not set in Camping.goes. #{opt}"
	end

end
