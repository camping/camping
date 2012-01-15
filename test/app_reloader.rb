require 'test_helper'
require 'fileutils'
require 'camping/reloader'

$counter = 0

module TestCaseReloader
  def reloader
    @reloader ||= Camping::Reloader.new(file)
  end

  def setup
    super
    reloader.reload!
    assert Object.const_defined?(:Reloader), "Reloader didn't load app"
  end

  def teardown
    super
    assert Object.const_defined?(:Reloader), "Test removed app"
    reloader.remove_apps
    assert !Object.const_defined?(:Reloader), "Reloader didn't remove app"
  end
end

class TestReloader < TestCase
  include TestCaseReloader
  BASE = File.expand_path('../apps/reloader', __FILE__)

  def file; BASE + '.rb' end

  def setup
    $counter = 0
    super
  end

  def test_counter
    assert_equal 1, $counter
  end
  
  def test_forced_reload
    reloader.reload!
    assert_equal 2, $counter
  end

  def test_mtime_reload
    reloader.reload
    assert_equal 1, $counter

    FileUtils.touch(BASE + '.rb')
    sleep 1
    reloader.reload
    assert_equal 2, $counter

    FileUtils.touch(BASE + '/reload_me.rb')
    sleep 1
    reloader.reload
    assert_equal 3, $counter
  end
end

class TestConfigRu < TestReloader
  BASE = File.expand_path('../apps/reloader', __FILE__)
  def file; BASE + '/config.ru' end

  def test_name
    assert_equal Reloader, reloader.apps[:reloader]
  end
end

