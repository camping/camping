require 'test_helper'
require 'fileutils'
require 'camping/loader'

# for Reloading stuff
module TestCaseLoaderToo
  def loader
    @loader ||= Camping::Loader.new(file)
  end

  def before_all
    super
    move_to_loader
    loader.reload!
    assert Object.const_defined?(:Loader), "Loader didn't load app"
  end

  def after_all
    assert Object.const_defined?(:Loader), "Test removed app"
    loader.remove_constants
    assert !Object.const_defined?(:Loader), "Loader didn't remove app"
    leave_loader
    super
  end
end

class TestLoading < TestCase
  include TestCaseLoaderToo
  BASE = File.expand_path('../apps/loader/camp', __FILE__)
  def file; BASE + '.rb' end

  def setup
    super
  end

  def teardown
    super
  end

  def test_silly; end

end
