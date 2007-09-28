require 'mongrel'
require 'mongrel/camping'

module Camping::Server
class Mongrel < Camping::Server::Base
    def initialize(conf, paths = [])
        super(conf, paths)
        raise unless conf.host && conf.port
    end
    def start
        raise "!! No apps loaded" unless self.apps.length > 0
        # get a reference to the server object for later use
        server = self
        # Need to use ::Mongrel... notation to avoid namespace clashes.
        @config = ::Mongrel::Configurator.new :host => @conf.host do
          listener :port => server.conf.port do
              if server.apps.length > 1
                  server.each do |app|
                      uri "/#{app.mount}", :handler => ::Mongrel::Camping::CampingHandler.new(app)
                      uri "/code/#{app.mount}", :handler => ViewSource.new(app)
                  end
                  uri "/", :handler => IndexHandler.new(server, @listener)
              else
                  uri "/", :handler => ::Mongrel::Camping::CampingHandler.new(server.apps.first)
              end
              uri "/favicon.ico", :handler => ::Mongrel::Error404Handler.new("")
          end
        end
        begin
            trap("INT") { @config.stop }
            @config.run
            puts "** Camping running on #{conf.host}:#{conf.port}."
            @config.join
        rescue Errno::EADDRINUSE
            raise "!! address #{conf.host}:#{conf.port} already in use."
        end

    end

    end
end   
class IndexHandler < Mongrel::HttpHandler
          def initialize(apps, server)
              @apps = apps
              @server = server
          end
          def process(req, res)
              res.start(200) do |head, out|
                  @apps.find_new_scripts do |app|
                      @server.register "/#{app.mount}", Mongrel::Camping::CampingHandler.new(app)
                      @server.register "/code/#{app.mount}", ViewSource.new(app)
                  end
                  out << @apps.index_page
              end
          end
end
class ViewSource < Mongrel::HttpHandler
  def initialize(app)
      @app = app
  end
  def process(req, res)
      res.start(200) do |head, out|
          head['Content-Type'] = 'text/plain'
          out << @app.view_source
      end
  end
end
