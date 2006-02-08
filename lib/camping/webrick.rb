require 'camping'
require 'webrick/httpservlet/abstract.rb'

class WEBrick::CampingHandler < WEBrick::HTTPServlet::AbstractServlet
    def initialize(server, klass)
        super(server, klass)
        @klass = klass
    end
    def do_GET(req, resp)
        controller = @klass.run((req.body and StringIO.new(req.body)), req.meta_vars)
        resp.status = controller.status
        controller.headers.each do |k, v|
            [*v].each do |vi|
                resp[k] = vi
            end
        end
        resp.body = controller.body
    end
    alias_method :do_POST, :do_GET
end
