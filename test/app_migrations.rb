require 'test_helper'

begin
  load File.expand_path('../apps/migrations.rb', __FILE__)

  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

  class Migrations::Test < TestCase
    def test_create
      Migrations.create
    end
  end
rescue MissingLibrary
  warn "Skipping migration tests"
end

