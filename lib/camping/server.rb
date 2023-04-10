require 'irb'
require 'erb'
require 'rack'
require 'rackup'
require 'camping/version'
require 'camping/reloader'
require 'camping/commands'

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
  class Server < Rackup::Server
    class Options

      def parse!(args)
        args = args.dup
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: camping Or: camping my-camping-app.rb"

          # opts.define_head "#{File.basename($0)}, the microframework ON-button for ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"

          opts.separator ""
          opts.separator "Specific options:"

          opts.on("-h", "--host HOSTNAME",
          "Host for web server to bind to (default is all IPs)") { |v| options[:Host] = v }

          opts.on("-p", "--port NUM",
          "Port for web server (defaults to 3301)") { |v| options[:Port] = v }

          opts.on("-c", "--console",
          "Run in console mode with IRB") { options[:server] = "console" }

          opts.on("-e", "--env ENVIRONMENT",
          "Sets the environment. (defaults: development)") { |v| options[:environment] = ENV['environment'] = v }

          server_list = ["thin", "webrick", "console", "puma", "tipi", "falcon"]
          opts.on("-s", "--server NAME",
          "Server to force (#{server_list.join(', ')})") { |v| options[:server] = v }

          opts.separator ""
          opts.separator "Common options:"

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on("-?", "--help", "Show this message") do
            puts opts
            exit
          end

          # Another typical switch to print the version.
          opts.on("-v", "--version", "Show version") { options[:version] = true }

          # Show Routes
          opts.on("-r", "--routes", "Show Routes") { options[:routes] = true }

        end

        opt_parser.parse!(args)

        if args.empty?
          args << "camp.rb"
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
      end
    end

    def opt_parser
      Options.new
    end

    def default_options
      super.merge({
        :Port => 3301
      })
    end

    def middleware
      h = super
      h["development"] << [XSendfile]
      h
    end

    def start

      commands = []
      ARGV.each do |cmd|
        commands << cmd
      end

      # Parse commands
      case commands[0]
      when "new"
        Camping::Commands.new_cmd(commands[1])
        exit
      end

      if options[:version] == true
        puts "Camping v#{Camping::VERSION}"
        exit
      end

      if options[:routes] == true
        @reloader.reload!
        r = @reloader
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { r.reload!; nil }
        ARGV.clear
        Camping::Commands.routes
        exit
      end

      if options[:server] == "console"
        puts "** Starting console"
        @reloader.reload!
        r = @reloader
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { r.reload!; nil }
        ARGV.clear
        IRB.start
        exit
      else
        @reloader.reload!
        r = @reloader
        Camping.make_camp
        name = server.name[/\w+$/]
        puts "** Starting #{name} on #{options[:Host]}:#{options[:Port]}"
        super
      end
    end

    # defines the public directory to be /public
    def public_dir
      File.expand_path('../public', @reloader.file)
    end

    # add the public directory as a Rack app serving files first, then the
    # current value of self, which is our camping apps, as an app.
    def app
      Rack::Cascade.new([Rack::Files.new(public_dir), self], [405, 404, 403])
    end

    # path_matches?
    # accepts a regular expression string
    # in our case our apps and controllers
    def path_matches?(path, *reg)
      p = T.(path)
      reg.each do |r|
        return true if Regexp.new(T.(r)).match?(p) && p == T.(r)
      end
      false
    end

    # Ensure trailing slash lambda
    T ||= -> (u) {
      u << "/" if u[-1] != "/"; u
    }

    # call(env) res
    # == How routing works
    #
    # The first app added using Camping.goes is set at the root, we walk through
    # the defined routes of the first app to see if there is a match.
    # With no match we then walk through every other defined app.
    # When we reach a matching route we call that app and Camping's router
    # handles the rest.
    #
    # Mounting apps at different directories is now explicit by setting the
    # url_prefix option:
    #
    #   camping.goes :Nuts          # Mounts Nuts at /
    #   module Auth
    #      set :url_prefix, "auth/"
    #   end
    #   camping.goes :Auth          # Mounts Auth at /auth/
    #   camping.goes :Blog          # Mounts Blog at /
    #
    # Note that routes that you set explicitly with R are not prefixed. This
    # us explicit control over routes:
    #
    #   module Auth::Controllers
    #      class Whatever < R '/thing/' # Mounts at /thing/
    #         def get
    #            render :some_view
    #         end
    #      end
    #   end
    #
    def call(env)
      if ENV['environment'] == 'development'
        @reloader.reload
        Camping.make_camp
      end

      # our switch statement iterates through possible app outcomes, no apps
      # loaded, one app loaded, or multiple apps loaded.
      case @reloader.apps.length
      when 0
        [200, {'content-type' => 'text/html'}, ["I'm sorry but no apps were found."]]
      when 1
        @reloader.apps.values.first.call(env) # When we have one
      else
        # 2 and up get special treatment
        @reloader.apps.each do |name, app|
          app.routes.each do |r|
            if (path_matches?(env['PATH_INFO'], r))
              return app.call(env)
              next
            end
          end
        end

        # Just return the first app if we didn't find a match.
        @reloader.apps.values.first.call(env)
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
