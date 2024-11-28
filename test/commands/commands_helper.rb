require 'helper'
require 'open3'
require 'camping'
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
	
	def leave_tmp
		Dir.chdir @original_dir
		`rm -rf test/tmp` if File.exist?('test/tmp')
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
	
	# returns all the files in the current working directory.
	def files_in_directory = Dir.glob('*').select {|f| !File.directory? f }
	
	# returns all the folders in the current working directory.
	def folders_in_directory = Dir.glob('*').select { |f| File.directory? f }
	
	# returns all the hidden files in the current working directory.
	def hidden_files_in_directory = Dir.glob(".*")
	
end
