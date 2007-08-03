require 'webrick/httpserver'
require 'camping/webrick'

module Camping::Server
class Webrick < Camping::Server::Base
    def initialize(conf, paths = [])
       super(conf, paths)
       # TODO exception
       raise unless conf.host && conf.port
       @s = WEBrick::HTTPServer.new(:BindAddress => conf.host, :Port => conf.port)
       conf
    end
    def start
        # TODO better exception
        raise unless self.length > 0
        if self.length > 1
          self.each do |app|
              @s.mount "/#{app.mount}", WEBrick::CampingHandler, app
              @s.mount_proc("/code/#{app.mount}") do |req, resp|
                  resp['Content-Type'] = 'text/plain'
                  resp.body = app.view_source
              end
          end
          @s.mount_proc("/") do |req, resp|
              self.find_new_scripts do |app|
                  @s.mount "/#{app.mount}", WEBrick::CampingHandler, app
                  @s.mount_proc("/code/#{app.mount}") do |req, resp|
                      resp['Content-Type'] = 'text/plain'
                      resp.body = app.view_source
                  end
              end
              resp.body = self.index_page
          end
        else
          @s.mount "/", WEBrick::CampingHandler, self.values.first
        end

        # Server up
        trap(:INT) do
          @s.shutdown
        end
        @s.start
    end
end
end
