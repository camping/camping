require 'test_helper'
require 'fileutils'
require 'camping/loader'

# for Reloading stuff
module TestCaseLoaderToo
  def loader
    @loader ||= Camping::Loader.new(file)
  end

  def setup
    super
    loader.reload!
    assert Object.const_defined?(:Loader), "Loader didn't load app"
  end

  # def teardown
  #   super
  #   assert Object.const_defined?(:Loader), "Test removed app"
  #   loader.remove_constants
  #   assert !Object.const_defined?(:Loader), "Loader didn't remove app"
  # end
end


class TestLoading < TestCase
  include TestCaseLoaderToo
  BASE = File.expand_path('../apps/loader/camp', __FILE__)
  def file; BASE + '.rb' end

  def move_to_loader
    @original_dir = Dir.pwd
    Dir.chdir "test"
    Dir.chdir "apps"
    Dir.chdir "loader"
  end

  # deletes the temporary directories found in the /apps directory for reloader testing.
  def leave_loader
	  Dir.chdir @original_dir
  end

  def setup
    move_to_loader
    super
  end

  def teardown
    leave_loader
    super
  end

  def test_silly; end

end
