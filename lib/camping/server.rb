require 'irb'
require 'erb'
require 'rack'
require 'camping/reloader'

# == The Camping Server (for development)
#
# Camping includes a pretty nifty server which is built for development.
# It follows these rules:
#
# * Load all Camping apps in a file.
# * Mount those apps according to their name. (e.g. Blog is mounted at /blog.)
# * Run each app's <tt>create</tt> method upon startup.
# * Reload the app if its modification time changes.
# * Reload the app if it requires any files under the same directory and one
#   of their modification times changes.
# * Support the X-Sendfile header.
#
# Run it like this:
#
#   camping blog.rb          # Mounts Blog at /
#
# And visit http://localhost:3301/ in your browser.
module Camping
  class Server < Rack::Server
    class Options
      if home = ENV['HOME'] # POSIX
        DB = File.join(home, '.camping.db')
        RC = File.join(home, '.campingrc')
      elsif home = ENV['APPDATA'] # MSWIN
        DB = File.join(home, 'Camping.db')
        RC = File.join(home, 'Campingrc')
      else
        DB = nil
        RC = nil
      end

      HOME = File.expand_path(home) + '/'

      def parse!(args)
        args = args.dup
        options = {}

        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: camping my-camping-app.rb"
          opts.define_head "#{File.basename($0)}, the microframework ON-button for ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
          opts.separator ""
          opts.separator "Specific options:"

          opts.on("-h", "--host HOSTNAME",
          "Host for web server to bind to (default is all IPs)") { |v| options[:Host] = v }

          opts.on("-p", "--port NUM",
          "Port for web server (defaults to 3301)") { |v| options[:Port] = v }

          db = DB.sub(HOME, '~/') if DB
          opts.on("-d", "--database FILE",
          "SQLite3 database path (defaults to #{db ? db : '<none>'})") { |db_path| options[:database] = db_path }

          opts.on("-C", "--console",
          "Run in console mode with IRB") { options[:server] = "console" }

          server_list = ["thin", "webrick", "console"]
          opts.on("-s", "--server NAME",
          "Server to force (#{server_list.join(', ')})") { |v| options[:server] = v }

          opts.separator ""
          opts.separator "Common options:"

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on_tail("-?", "--help", "Show this message") do
            puts opts
            exit
          end

          # Another typical switch to print the version.
          opts.on_tail("-m", "--mounting", "Shows Mounting Guide") do
            puts "Mounting Guide"
            puts ""
            puts "To mount your horse, hop up on the side and put it."
            exit
          end

          # Another typical switch to print the version.
          opts.on_tail("-v", "--version", "Show version") do
            puts Gem.loaded_specs['camping'].version
            exit
          end
        end

        opt_parser.parse!(args)

        if args.empty?
          puts opt_parser
          exit
        end

        options[:script] = args.shift
        options
      end
    end

    def initialize(*)
      super
      @reloader = Camping::Reloader.new(options[:script]) do |app|
        if !app.options.has_key?(:dynamic_templates)
		      app.options[:dynamic_templates] = true
	      end

        if !Camping::Models.autoload?(:Base) && options[:database]
          Camping::Models::Base.establish_connection(
            :adapter => 'sqlite3',
            :database => options[:database]
          )
        end
      end
    end

    def opt_parser
      Options.new
    end

    def default_options
      super.merge({
        :Port => 3301,
        :database => Options::DB
      })
    end

    def middleware
      h = super
      h["development"] << [XSendfile]
      h
    end

    def start
      if options[:server] == "console"
        puts "** Starting console"
        @reloader.reload!
        r = @reloader
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { r.reload!; nil }
        ARGV.clear
        IRB.start
        exit
      else
        name = server.name[/\w+$/]
        puts "** Starting #{name} on #{options[:Host]}:#{options[:Port]}"
        super
      end
    end

    def public_dir
      File.expand_path('../public', @reloader.file)
    end

    def app
      Rack::Cascade.new([Rack::Files.new(public_dir), self], [405, 404, 403])
    end

    # path_matches?
    # accepts a regular expression string
    # in our case our apps and controllers
    def path_matches?(path, *reg)
      reg.each do |r|
        return true if Regexp.new(r).match? path
      end
      false
    end

    # call(env) res
    # == How routing works
    #
    # The first app added using Camping.goes is set at the root, we walk through
    # the defined routes of the first app to see if there is a match.
    # With no match we then walk through every other defined app.
    # Each subsequent app defined is loaded at a directory named after them:
    #
    #   camping.goes :Nuts          # Mounts Nuts at /
    #   camping.goes :Auth          # Mounts Auth at /auth/
    #   camping.goes :Blog          # Mounts Blog at /blog/
    #
    def call(env)
      @reloader.reload
      apps = @reloader.apps

      case apps.length
      when 0
        [200, {'Content-Type' => 'text/html'}, ["I'm sorry but no apps were found."]]
      when 1
        apps.values.first.call(env) # When we have one
      else
        # 2 and up get special treatment
        count = 0
        apps.each do |name, app|
          if count == 0
            app.routes.each do |r|
              puts "match? path:#{env['PATH_INFO']} to #{r} "
              if (path_matches?(env['PATH_INFO'], r))
                next
              end
              return app.call(env) unless !(path_matches?(env['PATH_INFO'], r))
            end
          else
            mount = name.to_s.downcase
            case env["PATH_INFO"]
            when %r{^/#{mount}}
              env["SCRIPT_NAME"] = env["SCRIPT_NAME"] + $&
              env["PATH_INFO"] = $'
              return app.call(env)
            when %r{^/code/#{mount}}
              return [200, {'Content-Type' => 'text/plain', 'X-Sendfile' => @reloader.file}, []]
            end
          end
          count += 1
          puts "count: #{count}"
        end

        # Just return the first app if we didn't find a match.
        return apps.values.first.call(env)
      end
    end

    class XSendfile
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if key = headers.keys.grep(/X-Sendfile/i).first
          filename = headers[key]
          content = open(filename,'rb') { | io | io.read}
          headers['Content-Length'] = size(content).to_s
          body = [content]
        end

        return status, headers, body
      end

      if "".respond_to?(:bytesize)
        def size(str)
          str.bytesize
        end
      else
        def size(str)
          str.size
        end
      end
    end
  end
end
