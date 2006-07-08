# == About camping/fastcgi.rb
#
# Camping works very well with FastCGI, since your application is only loaded
# once -- when FastCGI starts.  In addition, this class lets you mount several
# Camping apps under a single FastCGI process, to help save memory costs.
#
# So where do you use the Camping::FastCGI class?  Use it in your application's
# postamble and then you can point your web server directly at your application.
# See Camping::FastCGI docs for more.
require 'camping'
require 'fcgi'

module Camping
# Camping::FastCGI is a small class for hooking one or more Camping apps up to
# FastCGI.  Generally, you'll use this class in your application's postamble.
#
# == The Smallest Example
#
#  if __FILE__ == $0
#    require 'camping/fastcgi'
#    Camping::FastCGI.start(YourApp)
#  end
#
# This example is stripped down to the basics.  The postamble has no database
# connection.  It just loads this class and calls Camping::FastCGI.start.
#
# Now, in Lighttpd or Apache, you can point to your app's file, which will
# be executed, only to discover that your app now speaks the FastCGI protocol.
#
# Here's a sample lighttpd.conf (tested with Lighttpd 1.4.11) to serve as example:
#
#   server.port                 = 3044
#   server.bind                 = "127.0.0.1"
#   server.modules              = ( "mod_fastcgi" )
#   server.document-root        = "/var/www/camping/blog/" 
#   server.errorlog             = "/var/www/camping/blog/error.log" 
#   
#   #### fastcgi module
#   fastcgi.server = ( "/" => ( 
#     "localhost" => ( 
#       "socket" => "/tmp/camping-blog.socket",
#       "bin-path" => "/var/www/camping/blog/blog.rb",
#       "check-local" => "disable",
#       "max-procs" => 1 ) ) )
#
# The file <tt>/var/www/camping/blog/blog.rb</tt> is the Camping app with
# the postamble.
#
# == Mounting Many Apps
#
#  require 'camping/fastcgi'
#  fast = Camping::FastCGI.new
#  fast.mount("/blog", Blog)
#  fast.mount("/tepee", Tepee)
#  fast.mount("/", Index)
#  fast.start
#
class FastCGI
    # Creates a Camping::FastCGI class with empty mounts.
    def initialize
        @mounts = {}
    end
    # Mounts a Camping application.  The +dir+ being the name of the directory
    # to serve as the application's root.  The +app+ is a Camping class.
    def mount(dir, app)
        dir.gsub!(/\/{2,}/, '/')
        dir.gsub!(/\/+$/, '')
        @mounts[dir] = app
    end
    # Starts the FastCGI main loop.
    def start
        FCGI.each do |req|
            path = req.env['SCRIPT_NAME'] + req.env['PATH_INFO']
            dir, app = @mounts.max { |a,b| match(path, a[0]) <=> match(path, b[0]) }
            unless dir and app
                dir, app = '/', Camping
            end
            req.env['SCRIPT_NAME'] = dir
            req.env['PATH_INFO'] = path.gsub(/^#{dir}/, '')
            req.out << app.run(req.in, req.env)
            req.finish
        end
    end

    # A simple single-app starter mechanism
    #
    #   Camping::FastCGI.start(Blog)
    #
    def self.start(app)
        cf = Camping::FastCGI.new
        cf.mount("/", app)
        cf.start
    end

    # Serve an entire directory of Camping apps. (See 
    # http://code.whytheluckystiff.net/camping/wiki/TheCampingServer.)
    #
    # Use this method inside your FastCGI dispatcher:
    #
    #   #!/usr/local/bin/ruby
    #   require 'rubygems'
    #   require 'camping/fastcgi'
    #   Camping::Models::Base.establish_connection :adapter => 'sqlite3', :database => "/path/to/db"
    #   Camping::FastCGI.serve("/home/why/cvs/camping/examples")
    # 
    def self.serve(path, index=nil)
        require 'camping/reloader'
        fast = Camping::FastCGI.new
        fast.mount("/", index) if index
        apps = Dir[File.join(path, '*.rb')].map do |script|
            app = Camping::Reloader.new(script)
            fast.mount("/#{app.mount}", app)
            app
        end
        fast.start
    end

    private

    def match(path, mount)
        m = path.match(/^#{Regexp::quote mount}(\/|$)/)
        if m: m.end(0)
        else  -1
        end
    end

end
end
