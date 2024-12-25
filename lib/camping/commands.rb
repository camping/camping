module Camping
  module CommandsHelpers

    # transform app_name to snake case
    def self.to_snake_case(string)
      string = string.to_s if string.class == Symbol
      string.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    # transform app_name to camel Case
    def self.to_camel_case(string)
      cammelled = ""
      to_snake_case(string).split("_").each do |seq|
        cammelled << seq.capitalize
      end
      cammelled
    end

    # Helper method that generates an app name from command line input.
    def self.app_name_from_input(app_name)
      app_name = :Camp if app_name == nil
      app_name = app_name.to_sym if app_name.class == String
      snake_app_name = to_snake_case(app_name)
      camel_app_name = to_camel_case(snake_app_name)

      {app_name: camel_app_name.to_sym, snake_name: snake_app_name, camel_name: camel_app_name}
    end

    RouteCollection = Struct.new(:routes)
    class RouteCollection
      # Displays formatted routes from a route collection
      # Assumes that Route structs are stored in :routes.
      def display
        current_app, current_controller = "", ""
        puts "App      VERB     Route"
        routes.each { |r|
          if current_app != r.app.to_s
            current_app = r.app.to_s
            puts "-----------------------------------"
            puts r.app_header
          end
          if current_controller != r.controller.to_s
            current_controller = r.controller.to_s
            puts r.controller_header
          end
          puts r.padded_message true
        }
      end

    end

    # Route Struct, for making and formatting a route.
    Route = Struct.new(:http_method, :controller, :app, :url)
    class Route

      def to_s
        "#{controller}: #{http_method}: #{url} - #{replace_reg url}"
      end

      # pad the controller name to be the right length, if we can.
      def padded_message(with_method = false)
        "#{pad}#{(with_method ? http_method.to_s.upcase.ljust(pad.length, " ") : pad)}#{replace_reg url}"
      end

      def app_header
        "#{app.to_s}"
      end

      def controller_header
        "#{pad}#{app.to_s}::#{controller.to_s}"
      end

      protected

      def http_methods
        ["get", "post", "put", "patch", "delete"]
      end

      def replace_reg(pattern = "")
        xstr = "([^/]+)";
        pattern = pattern.gsub(xstr, ":string").gsub("(\\d+)", ":integer") unless pattern == "/"
        pattern
      end

      def pad
        "         "
      end

    end

    class RoutesParser
      def self.parse(app)
        new(app).parse
      end

      def initialize(app = Camping)
        @parent_app, @routes = app, []
      end

      def parse
        @parent_app.make_camp
        collected_routes = []

        make_routes = -> (a) {

          a::X.all.map {|c|
            k = a::X.const_get(c)
            im = k.instance_methods(false).map!(&:to_s)
            methods = im & ["get", "post", "put", "patch", "delete"]
            if k.respond_to?:urls
              methods.each { |m|
                k.urls.each { |u|
                  collected_routes.append Camping::CommandsHelpers::Route.new(m,c,a.to_s,u)
                }
              }
            end
          }
        }

        if @parent_app == Camping
          @parent_app::Apps.each {|a|
            make_routes.(a)
          }
        else
          make_routes.(@parent_app)
        end

        Camping::CommandsHelpers::RouteCollection.new(collected_routes)
      end
    end

  end

  class Generators
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
hostname localhost
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

      # A helper method to spit out Routes for an application
      def routes(theApp = Camping, silent = false)
        routes = Camping::CommandsHelpers::RoutesParser.parse theApp
        routes.display unless silent == true
        return routes
      end

      def new_cmd(app_name=:Camp)

        # Normalize the app_name
        Camping::CommandsHelpers.app_name_from_input(app_name) => {app_name:, snake_name:, camel_name:}

        # make a directory then move there.
        # _original_dir = Dir.pwd
        Dir.mkdir("#{snake_name}") unless Dir.exist?("#{snake_name}")
        Dir.chdir("#{snake_name}")

        # generate a new camping app in a directory named after it:
        Generators::make_camp_file(camel_name)
        Generators::make_gitignore()
        Generators::make_rakefile()
        Generators::make_ruby_version()
        Generators::make_configkdl()
        Generators::make_gemfile()
        Generators::make_readme()
        Generators::make_public_folder()
        Generators::make_test_folder()

        # optionally add omnibus support
          # add src/ folder
          # add lib/ folder
          # add views/ folder

        # optionally add a local database too, through guidebook
          # add db/ folder
          # add db/migrate folder
          # add db/config.kdl
          # append migrations stuff to Rakefile.
          `ls`
      end

      # TODO: Create this generator
      # generates the apps folder from apps found in camp.rb or config.ru
      # def generate_apps_folder
      # end

    end
  end
end
