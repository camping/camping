module Camping
  module Generators
    class << self

      # write a file
      def write(file, content)
        raise "Cannot write to nil file." unless file
        folder = File.dirname(file)
        `mkdir -p #{folder}` unless File.exist?(folder)
        File.open(file, 'w') { |f| f.write content }
      end

      # read a file
      def read(file)
        File.read(file)
      end

      def make_camp_file(app_name="Tent")
        write "camp.rb", <<-RUBY
require 'camping'

Camping.goes :#{app_name}

module #{app_name}
  module Models
  end

  module Controllers
    class Index
      def get
        @title = "#{app_name}"
        render :index
      end
    end
  end

  module Helpers
  end

  module Views

    def layout
      html do
        head do
          title '#{app_name}'
          link :rel => 'stylesheet', :type => 'text/css',
          :href => '/styles.css', :media => 'screen'
        end
        body do
          h1 '#{app_name}'

          div.wrapper! do
            self << yield
          end
        end
      end
    end

    def index
      h2 "Let's go Camping"
    end

  end

end

RUBY
      end

      # makes a gitignore.
      def make_gitignore
        write '.gitignore', <<-GIT
.DS_Store
node_modules/
tmp/
db/camping.db
db/camping.sqlite3
db/camping.sqlite
GIT
      end

      def make_ruby_version
        write '.ruby-version', <<-RUBY
#{RUBY_VERSION}
RUBY
      end

      # writes a rakefile
      def make_rakefile
        write 'Rakefile', <<-TXT
# Rakefile
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'tempfile'
require 'open3'

task :default => :test
task :test => 'test:all'

namespace 'test' do
  Rake::TestTask.new('all') do |t|
    t.libs << 'test'
    t.test_files = FileList['test/test_*.rb']
  end
end
TXT
      end

      # write a config.kdl
      def make_configkdl
        write 'config.kdl', <<-KDL
// config.kdl
hostname "localhost"
KDL
      end

      # write a Gemfile
      def make_gemfile
        write 'Gemfile', <<-GEM
# frozen_string_literal: true
source 'https://rubygems.org'

gem 'camping'
gem 'falcon'
gem 'rake'

group :production do
  gem 'rack-ssl-enforcer'
end

group :development do
end

group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'minitest-hooks'
end

GEM
      end

      # write a README.md
      def make_readme
        write 'README.md', <<-READ
# Camping
Camping is really fun and I hope you enjoy it.

Start camping by running: `camping` in the root directory.

To start Camping in development mode run: `camping -e development

READ
      end

      def make_public_folder
        Dir.mkdir("public") unless Dir.exist?("public")
      end

      def make_test_folder
        Dir.mkdir("test") unless Dir.exist?("test")
        write 'test/test_helper.rb', <<-RUBY
$:.unshift File.dirname(__FILE__) + '/../'
# shift to act like we're in the regular degular directory

begin
  require 'rubygems'
rescue LoadError
end

require 'camping'
require 'minitest/autorun'
require 'minitest'
require 'rack/test'
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

class TestCase < Minitest::Test
  include Rack::Test::Methods

  def self.inherited(mod)
    mod.app = Object.const_get(mod.to_s[/\w+/])
    super
  end

  class << self
    attr_accessor :app
  end

  def body() last_response.body end
  def app()  self.class.app     end

  def assert_reverse
    begin
      yield
    rescue Exception
    else
      assert false, "Block didn't fail"
    end
  end

  def assert_body(str)
    case str
    when Regexp
      assert_match(str, last_response.body.strip)
    else
      assert_equal(str.to_s, last_response.body.strip)
    end
  end

  def assert_status(code)
    assert_equal(code, last_response.status)
  end

  def test_silly; end

end

RUBY
      end

    end
  end

  class Commands
    class << self
      # TODO: Create this generator
      # generates the apps folder from apps found in camp.rb or config.ru
      # def generate_apps_folder
      # end
    end
  end
end
