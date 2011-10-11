require 'test_helper'
require 'camping'

Camping.goes :Helpers

module Helpers::Helpers
  def frontpage
    R(Index)
  end

  def current_user
    User.new
  end
end

module Helpers::Models
  class User
    def name
      'Bob'
    end
  end
end

module Helpers::Controllers
  class Index
    def get
      URL('/').to_s
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

class Helpers::Test < TestCase
  def test_models
    get '/model'
    assert_body "Bob"
  end

  def test_controllers
    get '/users'
    assert_body "/"
  end

  def test_url
    get '/', {}, 'PATH_INFO' => ''
    assert_body "http://example.org/"
  end
end

