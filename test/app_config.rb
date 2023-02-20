require 'test_helper'
require 'camping'

module Config end

class Config::Test < TestCase

  def setup
    write_config()
    Camping.goes :Config
    @options = Camping::Apps.select{|a| a.name == "Config" }.first.options
    super
  end

  def teardown
    trash_config()
    super
  end

  def test_config
    assert @options.has_key? :hostname
    assert @options.has_key? :friends
    assert_equal @options[:friends].first, "_why", "_why isn't here?"
    assert_equal @options[:friends].length, 3, "Where are all our friends?"
    assert_equal @options.has_key?(:database), true, "By Golly the Database settings are missing."
    assert_equal @options[:database].length, 4, "We're missing some database settings."
    assert_equal @options[:database][:adapter], "sqlite3", "sqlite is missing. Not good."
  end

end
