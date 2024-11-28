require 'helper'
require 'camping'
require 'camping/commands'

Camping.goes :ForARide

class ForARide::Test < TestCase

  # the app_name_from_input method normalizes the input for the camping new command.
  # making sure it works right is kinda important.
  def test_app_name_from_input_method

    # input is expected, a symbol camel cased
    Camping::Tools.app_name_from_input(:AppApp) => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un expected, a camel cased string
    Camping::Tools.app_name_from_input("AppApp") => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un unexpected snake cased string
    Camping::Tools.app_name_from_input("app_app") => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un unexpected snake cased symbol
    Camping::Tools.app_name_from_input(:app_app) => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

  end

end
