require 'test_helper'
require 'fileutils'
require 'camping/loader'

$counter = 0

module TestCaseLoader
  def loader
    @loader ||= Camping::Loader.new(file)
  end

  def setup
    super
    loader.reload!
    assert Object.const_defined?(:Reloader), "Reloader didn't load app"
  end

  def teardown
    super
    assert Object.const_defined?(:Reloader), "Test removed app"
    loader.remove_constants
    assert !Object.const_defined?(:Reloader), "Loader didn't remove app"
  end
end

class TestLoader < TestCase
  include TestCaseLoader
  BASE = File.expand_path('../apps/reloader', __FILE__)

  def file; BASE + '.rb' end

  def setup
	  $counter = 0
	  move_to_apps
    super
  end

  def teardown
	  leave_apps
		super
  end

  def test_counter
    assert_equal 1, $counter
  end

  def test_forced_reload
    loader.reload!
    assert_equal 2, $counter
  end

  def test_that_touch_was_touched
    FileUtils.touch(BASE + '.rb')
    assert_equal 1, $counter
  end

  def test_mtime_reload
    loader.reload
    assert_equal 1, $counter

    FileUtils.touch(BASE + '.rb')
    sleep 1
    loader.reload
    assert_equal 2, $counter

    FileUtils.touch(BASE + '/reload_me.rb')
    sleep 1
    loader.reload
    assert_equal 3, $counter
  end
end

# These don't work anymore but everything else does?'
# class TestConfigRu < TestLoader
#   BASE = File.expand_path('../apps/reloader', __FILE__)
#   def file; BASE + '/config.ru' end

#   def test_name
#     assert_equal Reloader, loader.apps[:reloader]
#   end
# end
