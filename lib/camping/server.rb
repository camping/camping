require 'irb'
require 'erb'
require 'rack'
require 'camping/reloader'

# == The Camping Server (for development)
#
# Camping includes a pretty nifty server which is built for development.
# It follows these rules:
# 
# * Load all Camping apps in a directory or a file.
# * Load new apps that appear in that directory or that file.
# * Mount those apps according to their name. (e.g. Blog is mounted at /blog.)
# * Run each app's <tt>create</tt> method upon startup.
# * Reload the app if its modification time changes.
# * Reload the app if it requires any files under the same directory and one
#   of their modification times changes.
# * Support the X-Sendfile header.
#
# Run it like this:
#
#   camping examples/        # Mounts all apps in that directory
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
      
      HOME = File.expand_path('~') + '/'
      
      def parse!(args)
        args = args.dup
        options = {}
        
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: camping app1.rb app2.rb..."
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
          
          server_list = ["mongrel", "webrick", "console"]
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
        
        options[:scripts] = args
        options
      end
    end
    
    def initialize(*)
      super
      @reloader = Camping::Reloader.new
      @reloader.on_reload do |app|
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
      h["development"].unshift [XSendfile]
      h
    end

    def start
      if options[:server] == "console"
        puts "** Starting console"
        reload!
        this = self
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { this.reload!; nil }
        ARGV.clear
        IRB.start
        exit
      else
        name = server.name[/\w+$/]
        puts "** Starting #{name} on #{options[:Host]}:#{options[:Port]}"
        super
      end
    end
    
    def find_scripts
      scripts = options[:scripts].map do |path|
        if File.file?(path)
          path
        elsif File.directory?(path)
          Dir[File.join(path, '*.rb')]
        end
      end.flatten.compact
      
      @reloader.update(*scripts)
    end
    
    def reload!
      find_scripts
    end
    
    def app
      self
    end
    
    def call(env)
      reload!
      apps = @reloader.apps
      
      case apps.length
      when 0
        index_page(apps)
      when 1
        apps.values.first.call(env)
      else
        apps.each do |name, app|
          mount = name.to_s.downcase
          case env["PATH_INFO"]
          when %r{^/#{mount}}
            env["SCRIPT_NAME"] = env["SCRIPT_NAME"] + $&
            env["PATH_INFO"] = $'
            return app.call(env)
          when %r{^/code/#{mount}}
            return [200, {'Content-Type' => 'text/plain', 'X-Sendfile' => @reloader.script(app).file}, []]
          end
        end
        
        index_page(apps)
      end
    end
    
    def index_page(apps)
      [200, {'Content-Type' => 'text/html'}, [TEMPLATE.result(binding)]]
    end
    
    SOURCE = <<-HTML
<html>
  <head>
    <title>You are Camping</title>
    <style type="text/css">
      body { 
        font-family: verdana, arial, sans-serif; 
        padding: 10px 40px; 
        margin: 0; 
      }
      h1, h2, h3, h4, h5, h6 {
        font-family: utopia, georgia, serif;
      }
      h3 { display: inline; }
    </style>
  </head>
  <body>
    <% if apps.empty? %>
      <p>Good day.  I'm sorry, but I could not find any Camping apps.
      You might want to take a look at the console to see if any errors
      have been raised.</p>
    <% else %>
      <p>Good day.  These are the Camping apps you've mounted.</p>
      <ul>
      <% apps.each do |name, app| %>
        <li>
          <h3><a href="/<%= name.to_s.downcase %>"><%= app %></a></h3>
          <small> / <a href="/code/<%= name.to_s.downcase %>">View source</a></small>
        </li>
      <% end %>
      </ul>
    <% end %>
  </body>
</html>
    HTML
    
    TEMPLATE = ERB.new(SOURCE)
    
    class XSendfile
      def initialize(app)
        @app = app
      end
      
      def call(env)
        status, headers, body = @app.call(env)
        
        if key = headers.keys.grep(/X-Sendfile/i).first
          filename = headers[key]
          content = File.read(filename)
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
        def size(file)
          str.size
        end
      end
    end
  end
end