require 'helper'
require 'fileutils'
require 'camping/loader'

module Donuts end
module Loader end

def Loader.create
  puts "creating..."
  options.my_name = "slim shady"
end

# for Reloading stuff
module TestCaseLoaderToo
  def loader
    @loader ||= Camping::Loader.new(file)
  end

  def before_all
    super
    move_to_loader
    loader.reload!
  end

  def after_all
    leave_dir
    super
  end
end

class Donuts::Test < TestCase
  include TestCaseLoaderToo
  BASE = File.expand_path('../apps/loader/camp', __FILE__)
  def file; BASE + '.rb' end

  def test_that_our_apps_are_there
    assert loader.apps.include?(:Donuts), "Donuts not found: #{loader.apps}"
    assert loader.apps.include?(:Loader), "Loader not found: #{loader.apps}"
  end

  def test_output
    # Checks that the view is overwritten successfully more than once.
    get '/'
    assert_body "chunky bacon", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']

    # Checks that the view is not overwritten, because it's not reopened.
    get '/post'
    assert_body "_why", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']

    # Checks that a downstream view is loaded properly.
    get '/people'
    assert_body "People are great am I right?", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']
  end

  def test_create_method
    # Tests that our app even has a create method
    assert(Loader.respond_to?(:create), "test/app_loader.rb: Loader doesn't respond to create method")

    # Test that our create method code is actually run and that It has an effect.
    assert_equal("slim shady", Loader.options.my_name, "test/app_loader.rb: create method wasn't even loaded.")
  end

end
