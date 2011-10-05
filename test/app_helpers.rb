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
    get '/'
    assert_body "Bob"
  end

  def test_controllers
    get '/users'
    assert_body "/"
  end
end

