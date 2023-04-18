require 'test_helper'
require 'camping'
require 'camping/commands'

Camping.goes :Generator

class Generator::Test < TestCase

  def app_name(string)
    Camping::CommandsHelpers.app_name_from_input string
  end

  # the app_name_from_input method normalizes the input for the camping new command.
  # making sure it works right is kinda important.
  def test_app_name_from_input_method

    # input is expected, a symbol camel cased
    app_name(:AppApp) => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un expected, a camel cased string
    app_name("AppApp") => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un unexpected snake cased string
    app_name("app_app") => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

    # input is un unexpected snake cased symbol
    app_name(:app_app) => {app_name:, snake_name:, camel_name:}
    assert_equal :AppApp, app_name,   "app_name was unexpected: #{app_name}"
    assert_equal "app_app", snake_name, "snake_name was unexpected: #{snake_name}"
    assert_equal "AppApp", camel_name, "camel_name was unexpected: #{camel_name}"

  end

end
