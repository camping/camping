require_relative "common"

module Camping
	module Generators
	
		# generates a new camping application
		class New
			
			# call
			#
			# Let's you generate a new Camping app directory. Accepts a single 
			# parameter, app_name, which could be a camel or snake cased name. It 
			# converts it to a proper Constant name and then puts your app in a folder
			# named for your app.
			def self.call(app_name=:Camp)
				# Normalize the app_name
				CampTools.app_name_from_input(app_name) => {app_name:, snake_name:, camel_name:}
			
				# make a directory then move there.
				# _original_dir = Dir.pwd
				Dir.mkdir("#{snake_name}") unless Dir.exist?("#{snake_name}")
				Dir.chdir("#{snake_name}")
			
				# generate a new camping app in a directory named after it:
				Generators::make_camp_file(camel_name)
				Generators::make_gitignore()
				Generators::make_rakefile()
				Generators::make_ruby_version()
				Generators::make_configkdl()
				Generators::make_gemfile()
				Generators::make_readme()
				Generators::make_public_folder()
				Generators::make_test_folder()
			
				# optionally add omnibus support
					# add src/ folder
					# add lib/ folder
					# add views/ folder
			
				# optionally add a local database too, through guidebook
					# add db/ folder
					# add db/migrate folder
					# add db/config.kdl
					# append migrations stuff to Rakefile.
					`ls`
			end
			
		end
	end
end
