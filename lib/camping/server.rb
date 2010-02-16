require 'irb'
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
class Camping::Server
  attr_reader :reloader
  attr_accessor :conf

  def initialize(conf, paths)
    @conf = conf
    @paths = paths
    @reloader = Camping::Reloader.new
    connect(@conf.database) if @conf.database
  end
  
  def connect(db)
    unless Camping.autoload?(:Models)
      Camping::Models::Base.establish_connection(db)
    end
  end
  
  def find_scripts
    scripts = @paths.map do |path|
      case
      when File.file?(path)
        path
      when File.directory?(path)
        Dir[File.join(path, '*.rb')]
      end
    end.flatten.compact
    @reloader.update(*scripts)
  end
  
  def index_page(apps)
    welcome = "You are Camping"
    header = <<-HTML
<html>
  <head>
    <title>#{welcome}</title>
    <style type="text/css">
      body { 
        font-family: verdana, arial, sans-serif; 
        padding: 10px 40px; 
        margin: 0; 
      }
      h1, h2, h3, h4, h5, h6 {
        font-family: utopia, georgia, serif;
      }
    </style>
  </head>
  <body>
    <h1>#{welcome}</h1>
    HTML
    footer = '</body></html>'
    main = if apps.empty?
      "<p>Good day.  I'm sorry, but I could not find any Camping apps. "\
      "You might want to take a look at the console to see if any errors "\
      "have been raised.</p>"
    else
      "<p>Good day.  These are the Camping apps you've mounted.</p><ul>" + 
      apps.map do |mount, app|
        "<li><h3 style=\"display: inline\"><a href=\"/#{mount}\">#{app}</a></h3><small> / <a href=\"/code/#{mount}\">View source</a></small></li>"
      end.join("\n") + '</ul>'
    end
    
    header + main + footer
  end
  
  def app
    reload!
    all_apps = apps
    rapp = case all_apps.length
    when 0
      proc{|env|[200,{'Content-Type'=>'text/html'},index_page([])]}
    when 1
      apps.values.first
    else
      hash = {
        "/" => proc {|env|[200,{'Content-Type'=>'text/html'},index_page(all_apps)]}
      }
      all_apps.each do |mount, wrapp|
        # We're doing @reloader.reload! ourself, so we don't need the wrapper.
        app = wrapp.app
        hash["/#{mount}"] = app
        hash["/code/#{mount}"] = proc do |env|
          [200,{'Content-Type'=>'text/plain','X-Sendfile'=>wrapp.script.file},'']
        end
      end
      Rack::URLMap.new(hash)
    end
    rapp = Rack::ContentLength.new(rapp)
    rapp = Rack::Lint.new(rapp)
    rapp = XSendfile.new(rapp)
    rapp = Rack::ShowExceptions.new(rapp)
  end
  
  def apps
    @reloader.apps.inject({}) do |h, (mount, wrapp)|
      h[mount.to_s.downcase] = wrapp
      h
    end
  end
  
  def call(env)
    app.call(env)
  end
  
  def start
    handler, conf = case @conf.server
    when "console"
      puts "** Starting console"
      reload!
      this = self; eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { this.reload!; nil }
      ARGV.clear
      IRB.start
      exit
    when "mongrel"
      puts "** Starting Mongrel on #{@conf.host}:#{@conf.port}"
      [Rack::Handler::Mongrel, {:Port => @conf.port, :Host => @conf.host}]
    when "webrick"
      puts "** Starting WEBrick on #{@conf.host}:#{@conf.port}"
      [Rack::Handler::WEBrick, {:Port => @conf.port, :BindAddress => @conf.host}]
    end
    reload!
    handler.run(self, conf) 
  end
  
  def reload!
    find_scripts
    @reloader.reload!
  end

  # A Rack middleware for reading X-Sendfile. Should only be used in
  # development.
  class XSendfile
  
    HEADERS = [
      "X-Sendfile",
      "X-Accel-Redirect",
      "X-LIGHTTPD-send-file"
    ]
  
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers = Rack::Utils::HeaderHash.new(headers)
      if header = HEADERS.detect { |header| headers.include?(header) }
        path = headers[header]
        body = File.read(path)
        headers['Content-Length'] = body.length.to_s
      end
      [status, headers, body]
    end
  end    
end