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
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]


module CommandLineCommands

  def move_to_tmp
    @original_dir = Dir.pwd
    Dir.chdir "test"
    Dir.mkdir("tmp") unless Dir.exist?("tmp")
    Dir.chdir "tmp"
  end

  # fills a tmp directory with some sample stuff
  def make_summer_camp
  	Dir.mkdir("apps") unless Dir.exist?("apps")
    Dir.mkdir("lib") unless Dir.exist?("lib")
  end

  def leave_tmp
    Dir.chdir @original_dir
    `rm -rf test/tmp` if File.exist?('test/tmp')
  end

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
    write 'config.kdl', <<-TXT
// config.kdl
database {
  default adapter="sqlite3"  host="localhost" max_connections=5 timeout=5000
  development
  production adapter="postgres" database="kow"
}
hostname "crickets.com"
friends "_why" "judofyr" "chunky bacon"
TXT
  end

  def trash_config
    `rm -rf config.kdl` if File.exist?('config.kdl')
  end

end

class TestCase < MiniTest::Test
  include Rack::Test::Methods
  include CommandLineCommands

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

  def assert_status(code, message="")
    assert_equal(code, last_response.status, message)
  end

  def test_silly; end
end
