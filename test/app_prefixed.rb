require 'helper'
require 'camping'

Camping.goes :Prefixed


module Prefixed
  set :url_prefix, "pages"
end

module Prefixed::Helpers
  def frontpage
    R(Index)
  end

  def current_user
    User.new
  end
end

module Prefixed::Models
  class User
    def name
      'Bob'
    end
  end
end

module Prefixed::Controllers
  class Index
    def get
      URL('/').to_s
    end
  end

  class Friends
    def get
      self / "/view/1"    #=> "/pages/view/1"
    end
  end

  class Helpy
    def get
      @url_prefix
    end
  end

  class Model
    def get
      current_user.name
    end
  end

  class Users
    def get
      frontpage
    end
  end
end

class Prefixed::Test < TestCase

  def test_url_helper_use_prefix
    get '/pages/model'
    assert_body "Bob"
  end

  def test_slash_helper_use_prefix
    get '/pages/friends'
    assert_body "/pages/view/1"
  end

  def test_prefix_ivar
    get '/pages/helpy'
    assert_body "pages/"
  end

  # Test that R(Index) produces "/pages/"
  def test_r_helper_use_prefix
    get '/pages/users'
    assert_body "/pages"
  end

  def test_controller_routes_use_prefix
    get '/pages', {}, 'PATH_INFO' => '/pages'
    assert_body "http://example.org/pages/"
  end
end
