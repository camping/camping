require 'helper'

require 'tempfile'
require 'socket'
require 'webrick'
require 'open-uri'
require 'net/http'
require 'net/https'

require 'camping/command'

begin
 require 'stackprof'
 require 'tmpdir'
rescue LoadError
else
 test_profile = true
end

describe Camping::Command do
 argv = Camping::Command::ARGV = []
 define_method(:argv) { argv }

 before {
   argv.clear
   @original_dir = Dir.pwd
   Dir.chdir "test/integration"
 }

 after {
   Dir.chdir @original_dir
 }

 # Probably need to revise this for the camping port
 #def app
 #  lambda { |env| [200, { 'content-type' => 'text/plain' }, ['success']] }
 #end

 # learn what this is doing.
 def with_stderr
   old, $stderr = $stderr, StringIO.new
   yield $stderr
 ensure
   $stderr = old
 end
 
 it "Runs a default server when no options are passed to camping command" do
  pidfile = Tempfile.open('pidfile') { |f| break f }
  FileUtils.rm pidfile.path
  
  puts "doing stuff"
  
  t = Thread.new {
    Camping::Command.call {|s|
      puts "ore stuff"
      Thread.current[:server] = s
    }
  }
  t.join(0.1) until t[:server] && t[:server].status != :Stop
  
  Process.kill(:INT, $$)
  t.join
 end

 # # Fails a lot
 # # TODO: figure out why this fails and if we need to be testing this the
 # # right way.
 # it "runs a server" do
 #   pidfile = Tempfile.open('pidfile') { |f| break f }
 #   FileUtils.rm pidfile.path
 #   server = Camping::Server.new(
 #     app: "FOO",
 #     environment: 'none',
 #     pid: pidfile.path,
 #     Port: TCPServer.open('localhost', '0'){|s| s.addr[1] },
 #     Host: 'localhost',
 #     Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
 #     AccessLog: [],
 #     daemonize: false,
 #     server: 'webrick'
 #   )
 #   t = Thread.new { server.start { |s| Thread.current[:server] = s } }
 #   t.join(0.01) until t[:server] && t[:server].status != :Stop
 #   body = if URI.respond_to?(:open)
 #           URI.open("http://localhost:#{server.options[:Port]}/") { |f| f.read }
 #         else
 #           open("http://localhost:#{server.options[:Port]}/") { |f| f.read }
 #         end
 #   body.must_include 'Let&#39;s go Camping'
 #   Process.kill(:INT, $$)
 #   t.join
 #   open(pidfile.path) { |f| f.read.must_equal $$.to_s }
 # end

#  it "Loads the kindling initializers" do
#    pidfile = Tempfile.open('pidfile') { |f| break f }
#    FileUtils.rm pidfile.path
#    server = Camping::Server.new
#
#    starty_file = false
#    starty_name = "Starty"
#
#    t = Thread.new {
#      server.start { |s|
#        Thread.current[:server] = s
#        starty_file = Object.constants.include? :Starty
#        starty_name = Starty.name
#      }
#    }
#    t.join(0.01) until t[:server] && t[:server].status != :Stop
#
#    starty_file.must_equal true
#    starty_name.must_equal "Starty"
#
#    Process.kill(:INT, $$)
#    t.join
#  end

end
