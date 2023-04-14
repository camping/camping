# How does Camping work?
This is an academic document written to help people, but mostly me, understand what Camping is doing and in what sequence. Why? Because I want to make camping better, but how do you make it better unless you understand what you've got?

# Start
Camping starts off with some simple code you type: `camping nuts.rb` into your terminal and the camping gem is loaded and executed. This assumes that you've installed camping via ruby gems: `gem install camping`. Gems are then given a binary command you can use on the command line, in our case **camping**. The camping command accepts a file as an argument and maybe some options. This command calls a *binary* that's found the camping gem, this is what it looks like:
```ruby
#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'camping'
require 'camping/server'

begin
  Camping::Server.start
rescue OptionParser::ParseError => ex
  STDERR.puts "!! #{ex.message}"
  puts "** use `#{File.basename($0)} --help` for more details..."
  exit 1
end
```

First wee see `$:.unshift File.dirname(__FILE__) + "/../lib"`, `$:`, is a global variable, that contains the loadpath for scripts. Every ruby file is a script, you may be more familiar with `$LOAD_PATH` which is an alias for the `$:` global. Next `unshift` is an array method that prepends an item to the beginning of an array. `File` is a builtin ruby class that lets you work with files. `File.dirname(file)` returns a string of the complete file path of the file given, except for the file's name. In our case we're using `__FILE__` to return the current file name, which is the binary file in the camping gem. the last portion: `+ "/../lib"` appends the string to the directory path that we just got. All of this is done to ensure that the `lib` folder where all of camping's code resides is added to the script load path.

Next we require camping:
```ruby
require 'camping'
require 'camping/server'
```

Which loads camping and it's server code in to the current script context.

```ruby
  Camping::Server.start
```

The above code finally Starts the camping server. So let's take a look at the server:

```ruby
require 'irb'
require 'erb'
require 'rack'
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
          opts.on("-?", "--help", "Show this message") do
            puts opts
            exit
          end

          # Another typical switch to print the version.
          opts.on("-m", "--mounting", "Shows Mounting Guide") do
            puts "Mounting Guide"
            puts ""
            puts "To mount your horse, hop up on the side and put it."
            exit
          end

          # Another typical switch to print the version.
          opts.on("-v", "--version", "Show version") do
            puts Gem.loaded_specs['camping'].version
            exit
          end

        end

        opt_parser.parse!(args)

        # If no Arguments were called.
        if args.empty?
          args << "cabin.rb" # adds cabin.rb as a default camping entrance file
        end

        # Parses the first argument as the script to load into the server.
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

      # our switch statement iterates through possible app outcomes, no apps
      # loaded, one app loaded, or multiple apps loaded.
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

        if key = headers.keys.grep(/c-sendfile/i).first
          filename = headers[key]
          content = open(filename,'rb') { | io | io.read}
          headers['content-length'] = size(content).to_s
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
```

The beginning of Server loads the required code to get Camping started, and then opens the `Camping` module:

```ruby
module Camping
  class Server < Rack::Server
  end
end
```

`Server` inherits from `Rack::Server`. Camping is Rack based to give ourselves a predictable interface for our web server code. Consequentally a lot of utilities useful for webservers are just baked into Rack, It gives Camping the chance to do what it does best, magic!

The first class declared in `Server` is called `Options`. It's in charge of parsing the command line options supplied to camping, and then supplying those options as a hash for the program further down the line. This class is declared inside of the `Server` class so that we can encapsulate the behaviour of options within the server. Which is pretty nice. Next is initialize:

```ruby
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
```

`initialize` is the method called whenever you instantiate a new object of a class. You'll notice that the line of code in the method is a call to `super`. Because `Camping::Server` is a subclass of `Rack::Server`, and to get things rolling we first call `Rack::Server`'s initialize. Afterwards we setup the reloader, and optionally include the database.

When you call super naked like that it passes along whatever arguments were sent to the method that called super. In our case It's a splat: `initialize(*)`, so everything is sent along.





Remember earlier from the Camping binary where we start the server? : `Camping::Server.start`, You may notice that this is a call to a class method `start`, but we don't declare any class methods in `Camping::Server` only instance methods.
