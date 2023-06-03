require 'test_helper'
require 'fileutils'
require 'camping/loader'

$counter = 0

# for Reloading stuff
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
  def file; BASE + '/reloader.rb' end

  def setup
    $counter = 0
    move_to_reloader
    super
    loader.start unless loader.processing_events?
  end

  def teardown
    loader.stop
    leave_reloader
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
    FileUtils.touch(BASE + '/reloader.rb')
    assert_equal 1, $counter
  end

  def test_mtime_reload
    loader.reload
    assert_equal 1, $counter

    FileUtils.touch(BASE + '/reloader.rb')
    loader.reload
    assert_equal 2, $counter

    FileUtils.touch(BASE + '/reload_me.rb')
    loader.reload
    assert_equal 3, $counter
  end
end

class TestConfigRu < TestLoader
  BASE = File.expand_path('../apps/reloader', __FILE__)
  def file; BASE + '/config.ru' end

  def test_name
    assert_equal Reloader, loader.apps[:reloader]
  end
end
