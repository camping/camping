require 'test_helper'
require 'fileutils'
require 'camping/loader'

module Donuts end
module Loader end

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
    leave_loader
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
    get '/'
    assert_body "chunky bacon", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']

    get '/post'
    assert_body "_why", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']

    get '/people'
    assert_body "People are great am I right?", "Response is wrong in the loader."
    assert_equal "text/html", last_response.headers['content-type']
  end

end
