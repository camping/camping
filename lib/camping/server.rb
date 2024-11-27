require 'irb'
require 'erb'
require 'rack'
require 'rackup'
require 'camping/version'
require 'gear/firewatch'
require 'camping/loader'
require 'camping/commands'

require 'camping'

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
#    class Options
#
#      def parse!(args)
#        args = args.dup
#        options = {}
#        opt_parser = OptionParser.new("", 24, '  ') do |opts|
#          opts.banner = "Usage: camping Or: camping my-camping-app.rb"
#
#          # opts.define_head "#{File.basename($0)}, the microframework ON-button for ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
#
#          opts.separator ""
#          opts.separator "Specific options:"
#
#          opts.on("-h", "--host HOSTNAME",
#          "Host for web server to bind to (default is all IPs)") { |v| options[:Host] = v }
#
#          opts.on("-p", "--port NUM",
#          "Port for web server (defaults to 3301)") { |v| options[:Port] = v }
#
#          opts.on("-c", "--console",
#          "Run in console mode with IRB") { options[:server] = "console" }
#
#          opts.on("-e", "--env ENVIRONMENT",
#          "Sets the environment. (defaults: development)") { |v| options[:environment] = ENV['environment'] = v }
#
#          server_list = ["thin", "webrick", "console", "puma", "tipi", "falcon"]
#          opts.on("-s", "--server NAME",
#          "Server to force (#{server_list.join(', ')})") { |v| options[:server] = v }
#
#          opts.separator ""
#          opts.separator "Common options:"
#
#          # No argument, shows at tail.  This will print an options summary.
#          # Try it and see!
#          opts.on("-?", "--help", "Show this message") do
#            puts opts
#            exit
#          end
#
#        end
#
#        opt_parser.parse!(args)
#
#        if args.empty?
#          args << "camp.rb"
#        end
#
#        options[:script] = args.shift
#        options
#      end
#    end

    ##
    # new
    #
    # Camping::Server new method makes a new Camping Server. Well not exactly.
    # We probably need to rename this. What it does is make a new Camping stack.
    # A rack compatible app ready to be run in a server.
    def initialize(options = {})
      raise StandardError.new("Camping::Server#new accepts a Hash.") unless (options.is_a?(Hash))

      @ignore_options = []
    
      if options
        @use_default_options = false
        @options = options
        @app = options[:app] if options[:app]
      else
        @use_default_options = true
        @options = parse_options(ARGV)
      end

      if options.empty? || options.key?(:script) ==
        options[:script] = "camp.rb"
      end
       
      @reloader = Camping::Reloader.new(options[:script]) do |app|
        if !app.options.has_key?(:dynamic_templates)
         app.options[:dynamic_templates] = true
        end
      end
      
      load_kindling()
      
      # Force a reload of Camping, after the kindling is called. This makes it load the app files.
      @reloader.reload!
      @reloader
    end
    
    ##
    # load_kindling
    #
    # An internal method that requires the kindling files. Used before the reloader, reloads.
    def load_kindling
      Dir['kindling/*.rb'].each do |kindling|
        require_relative File.expand_path(kindling)
      end
    end

    #def default_options
    #  super.merge({
    #    :Port => 3301
    #  })
    #end

    # redefine logging middleware
    class << self
      def logging_middleware
        lambda { |server|
          /CGI/.match?(server.server.name) || server.options[:quiet] ?  nil : [Camping::Firewatch, $stderr]
        }
      end
    end

    def middleware
      h = super
      h["development"] << [XSendfile]
      h["deployment"] << [XSendfile]
      h
    end

    # Starts the Camping Server. Camping server inherits from Rack::Server so
    # referencing their documentation would be a good idea.
    # @file: String, file location for a camp.rb file.
    def start(file = nil)
      commands = ARGV
      # Parse commands
      case commands[0]
      when "new"
        Camping::Commands.new_cmd(commands[1])
        exit
      end

      if options[:server] == "console"
        puts "** Starting console"
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { r.reload!; nil }
        ARGV.clear
        IRB.start
        exit
      else
        name = server.name[/\w+$/]
        puts "** Starting #{name} on #{options[:Host]}:#{options[:Port]}"
        super()
      end
    end

    # defines the public directory to be /public
    def public_dir
      File.expand_path('../public', @reloader.file)
    end

    # add the public directory as a Rack app serving files first, then the
    # current value of self, which is our camping apps, as an app.
    def app # WARNING: I don't think this is even being used!!!
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


module Camping

  # makes a new Camp, parsing Camp.rb, and builds all our wonderful apps, etc...
  # intended to be loaded from a config.ru file like so:
  #
  #   require 'camping'
  # 
  #   app = Camping.make
  #   run app
  # 
  # because camping sets up it's own middleware, and rack stuff internally,
  # It's not necessary to put much else in the config.ru file.
  #
  # The make method doesn't require any methods. It will parse ARGV, if it's
  # around, and start up from there.
  def self.make = Camping::Server.new
end
