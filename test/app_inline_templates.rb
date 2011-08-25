require 'test_helper'
require 'camping'

Camping.goes :Inline

module Inline::Controllers
  class Index
    def get
      @world = "World"
      render :index
    end
  end

  class UserX
    def get(name)
      @name = name
      render :user
    end
  end
end

class Inline::Test < TestCase
  def test_inline
    get '/'
    assert_body "Hello World"

    get '/user/Bluebie'
    assert_body "My name is Bluebie"
  end
end

__END__

@@ index.erb
Hello <%= @world %>

@@ user.erb
My name is <%= @name %>

