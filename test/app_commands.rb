require 'helper'
require 'camping'
require 'camping/commands'

Camping.goes :Commands

class Commands::Test < TestCase

  def app_name(string)
    Camping::Tools.app_name_from_input string
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

  # Generates expected directory Structure
  #
  # Camping has an expected directory structure:
  #
  #   .gitignore
  #   .ruby-version
  #   Gemfile
  #   Rakefile
  #   camp.rb
  #   config.kdl
  #   src/
  #   lib/
  #   public/
  #   test/
  #   apps/
  #
  # This test checks to make certain that the generator command creates this
  # directory structure.
  def test_app_generates_directory_structure
    move_to_tmp
    Camping::Commands.new_cmd

    res, ignored = [Dir.glob('*').select {|f| !File.directory? f },
    Dir.glob('*').select {|f| File.directory? f }], Dir.glob(".*")

    assert res[0].include?('Gemfile'), "mising Gemfile"
    assert res[0].include?('README.md'), "missing README.md"
    assert res[0].include?('Rakefile'), "missing Rakefile"
    assert res[0].include?('camp.rb'), "missing camp.rb"
    assert res[0].include?('config.kdl'), "missing config.kdl"
    assert res[1].include?('public'), "missing public folder."
    assert res[1].include?('test'), "missing test folder."

    assert ignored.include?('.gitignore'), ".gitignore is missing."
    assert ignored.include?('.ruby-version'), ".ruby-version is missing."

    leave_tmp
  end

end
