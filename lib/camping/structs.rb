module Camping
	module Structs
	end

	# Structs

	# Route
	# A struct representing a routing in Camping.
	# name: {String} The name of the route. Matches it's class Name
	# url: {String} The url that it matches.
	# controller: {Object} The Controller that the URL Pattern is handled by.
	# method: {Symbol} The method that is sent to the object when the route is called
	#   route is matched.
	Route = Struct.new(:name,:url,:controller,:method)

	# Metadata
	# A struct containing an app's metadata.
	# @name: {String} The app name.
	# @parent: {Object} The app's parent app, Defaults to Camping.
	# @root: {String} The app's root url. it's URL Prefix, basically.
	# @location: {Location}, A struct containing a file name, and line number.
	Metadata = Struct.new(:name,:parent,:root,:location)

	# Location
	# A struct containing an app's definition location
	# @file: {String} The string location and name of the file
	# @line_number: {String} The line number in that file where the app was made.
	Location = Struct.new(:file,:line_number)

end
