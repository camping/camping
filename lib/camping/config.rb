# frozen_string_literal: true
# lib/camping/config
# load and parse settings.

begin
	require 'kdl'
rescue LoadError => e
	raise "kdl could not be loaded (is it installed?): #{e.message}"
end

module Camping
	class << self
		def configure(app)
			config = Kuddly.get_config()
			config.each do |k,v|
				app.set(k.to_sym, v)
			end unless config == nil
		end
	end

	# Namespace to hide all of the KDL Configure stuff.
	module Kuddly

		# parses a kdl file into a kdl document Object.
		# returns nil if it's false. Also assumes that the file is exists.
		# an optional silence_warnings parameter is set to false. This is used for
		# testing.
		def self.parse_kdl(config_file = nil, silence_warnings = false)
			begin
				kdl_string = File.open(config_file).read
			rescue => error # Errno::ENOENT
				puts ""
				puts "Error trying to read a config file: \"#{error}.\""
				puts "  Attempted to open: #{config_file}"
				puts "  Current directory: #{Dir.pwd}"
				puts "  files in directory: #{Dir.glob('*')}"
				puts ""
			end

			begin
				kdl_doc = KDL.parse_document(kdl_string)
			rescue => error
				warn "#{error}"
				# parse error message to get line number and column:
				message = Van.kdl_error_message(kdl_string, error.message, error)
				m = error.message.match( /\((\d)+:(\d)\)/ )

				line, column = m[1].to_i, m[2].to_i

				warn("\nError parsing config: #{config_file}, on line: #{line}, at column: #{column}.", message, "#{error.message}", uplevel: 1) unless silence_warnings
			end

			kdl_doc
		end

		# Maps kdl settings. Settings Example:
		# ```
		# database {
		#	  default adapter="sqlite3" database="#{database}" host="localhost" max_connections=5 timeout=5000
		#	  development
		#   test
		#	  production adapter="postgres" database="kow"
		# }
		# ```
		def self.map_kdl(kdl_doc=nil)
			configs = {}

			if kdl_doc

				# We have a kdl document, so that's good.
				# iterate through each top level node to see what kind of data we have.
				kdl_doc.nodes.each do |d|
					config_name = d.name.to_sym
					configs[config_name] = {}

					if d.children.length > 0
						# we've got kids!
						# This node will have sub nodes with properties
						d.children.each do |en|
							env_name = en.name.to_sym
							# parse the settings for each environment
							configs[config_name][env_name] = {}
							en.properties.each do |key, value|
								configs[config_name][env_name][key.to_sym] = value.value
							end
						end
					else
						# we've got raw data, so place it into a default hash spot.
						vals = []
						if d.arguments.length > 1
							d.arguments.each { |v| vals << v.value }
						else
							vals = d.arguments.first.value
						end

						configs[config_name]['default'] = vals
					end
				end
			end

			configs
		end

		# get_config
		# searches for any kdl document inside of the root folder
		# Then parses it, and merges the data based on the current environment.
		def self.get_config(provided_config_file = nil)

			config_file, kdl_doc, merged_configs = provided_config_file, nil, {}
			config_file = get_root_config_file() unless provided_config_file != nil

			# If the config file is just nil then we probably don't have one.
			return nil unless config_file != nil

			# parses then maps the kdl
			configs = map_kdl(parse_kdl(config_file))
			env = ENV['environment'] ||= "development"

			configs.each do |key, setting|
				if setting.has_key? :default && env.to_sym
					merged_configs[key] = setting[:default].merge(setting[env.to_sym])
				else
					merged_configs[key] = setting['default']
				end
			end

			merged_configs
		end

		# get kdl config file
		def self.get_root_config_file(search_pattern = "config.kdl")
			Dir.glob(search_pattern).first
		end

	end

end


