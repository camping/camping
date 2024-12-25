$:.unshift File.dirname(__FILE__) + '/../lib'
$VERBOSE = nil

begin
  require 'rubygems'
rescue LoadError
end

if ENV['ABRIDGED']
  require 'camping'
else
  require 'camping-unabridged'
end

require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'
require 'minitest/hooks'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

module CommandLineCommands

  def move_to_tmp
    @original_dir = Dir.pwd
    Dir.chdir "test"
    Dir.mkdir("tmp") unless Dir.exist?("tmp")
    Dir.chdir "tmp"
  end

  def leave_tmp
    Dir.chdir @original_dir
    `rm -rf test/tmp` if File.exist?('test/tmp')
  end

  # reloader helpers:
  # move_to_apps
  # moves to the apps directory in /test
  def move_to_reloader
    @original_dir = Dir.pwd
    Dir.chdir "test"
    Dir.chdir "apps"
    Dir.chdir "reloader"
   	Dir.mkdir("apps") unless Dir.exist?("apps")
    Dir.mkdir("lib") unless Dir.exist?("lib")
  end

  # deletes the temporary directories found in the /apps directory for reloader testing.
  def leave_reloader
    leave_dir
    `rm -rf test/apps/reloader/apps` if File.exist?('test/apps/reloader/apps')
    `rm -rf test/apps/reloader/lib` if File.exist?('test/apps/reloader/lib')
  end

  # Moves to the loader directory
  def move_to_loader
    @original_dir = Dir.pwd
    Dir.chdir "test"
    Dir.chdir "apps"
    Dir.chdir "loader"
   	Dir.mkdir("apps") unless Dir.exist?("apps")
    Dir.mkdir("lib") unless Dir.exist?("lib")
  end

  # generic move_to(dir) method
  def move_to(dir)
    @original_dir = Dir.pwd
    Dir.chdir dir
  end

  # generic leave_dir method
  def leave_dir = Dir.chdir @original_dir

  def write(file, content)
    raise "cannot write nil" unless file
    file = tmp_file(file)
    folder = File.dirname(file)
    `mkdir -p #{folder}` unless File.exist?(folder)
    File.open(file, 'w') { |f| f.write content }
  end

  def read(file)
    File.read(tmp_file(file))
  end

  def tmp_file(file)
    "#{file}"
  end

  def write_config
    write 'config.kdl', <<-KDL
// config.kdl
database {
  default adapter=sqlite3 host=localhost max_connections=5 timeout=5000
  development
  production adapter=postgres database=kow
}
hostname crickets.com
friends _why judofyr "chunky bacon"
KDL
  end

  def trash_config
    `rm -rf config.kdl` if File.exist?('config.kdl')
  end

end

class TestCase < Minitest::Test
  include Rack::Test::Methods
  include CommandLineCommands
  include Minitest::Hooks

  def self.inherited(mod)
    mod.app = Object.const_get(mod.to_s[/\w+/])
    super
  end

  class << self
    attr_accessor :app
  end

  def setup
    super
    Camping.make_camp
  end

  def body() last_response.body end
  def app()  self.class.app     end

  # adding this because sometimes the response is wonky???
  def response_body() last_response.to_a end

  def assert_reverse
    begin
      yield
    rescue Exception
    else
      assert false, "Block didn't fail"
    end
  end

  def assert_body(str, message="")
    case str
    when Regexp
      assert_match(str, last_response.body.strip, message)
    else
      assert_equal(str.to_s, last_response.body.strip, message)
    end
  end

  def assert_log(str, message="")
    logs = File.read Dir["./**/logs/development.log"].first
    assert(logs.to_s.match?(str), message)
  end

  def assert_status(code, message="")
    assert_equal(code, last_response.status, message)
  end

  def test_silly; end
end
