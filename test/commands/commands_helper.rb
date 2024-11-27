require 'helper'
require 'open3'
require 'camping/command'
require 'fileutils'

class CampingFeatureHelper < CampingUnitTest
	
	class Paths
		SOURCE = Pathname.new(File.expand_path("../..", __dir__))
		
		class << self
			def test_dir = source_dir.join("tmp", "camping")
			
			def camping_bin = source_dir.join("bin", "camping")
			
			def source_dir = SOURCE
			
			def root_files
				[
					"camp.rb",
					"tmp"
				]
			end
		end
		
	end

	def before_all
		move_to_tmp()
		super
	end
	
	def after_all
		leave_tmp()
	end
	
	##
	# run_camping
	#
	# runs camping using the commands, arguments, etc... for exec_command.
	def run_camping(command, args = "", skip_status_check: false)
		args = args.strip.split
		process, output = exec_command("ruby", Paths.camping_bin.to_s, command, *args)
		unless skip_status_check
		assert process.exitstatus.zero?, "Camping process failed: #{process} \n#{output}"
		end
		
		[process, output]
	end
	
	##
	# exec_command
	#
	# executes a command on the command line.
	def exec_command(*args)
		stdin, stdout, stderr, process = Open3.popen3(*args)
		out = stdout.read.strip
		err = stderr.read.strip
		
		[stdin, stdout, stderr].each(&:close)
		[process.value, out + err]
	end
	
	##
	# create_directory
	#
	# Creates a directory from the supplied parameter: +dir+ which should be a *String*.
	def create_directory(dir)
		if Paths.root_files.include?(dir)
			FileUtils.mkdir_p(dir)
		else
			dir_in_src = File.join("src", dir)
			FileUtils.mkdir_p(dir_in_src) unless File.directory?(dir_in_src)
		end
	end
	
	##
	# create_file
	#
	# creates a file with the provided text. params: +file+, +text+, are the file 
	# name as a string and the file text also as a *String*.
	def create_file(file, text)
		if Paths.root_files.include?(file.split("/").first)
			File.write(file, text)
		else
			FileUtils.mkdir_p("src")
			File.write(File.join("src", file), text)
		end
	end
	
end
