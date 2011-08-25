require 'test_helper'
require 'camping'

Camping.goes :SC

module SC::Controllers
  get '/' do
    "Hello World!"
  end

  post '/(\d+)' do |i|
    i
  end
end

class SC::Test < TestCase
  def test_index
    get '/'
    assert_body "Hello World!"
  end

  def test_paramaters
    post '/123'
    assert_body "123"
  end
end

