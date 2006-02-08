require 'camping'
require 'mongrel'

class Mongrel::CampingHandler < Mongrel::HttpHandler
    def initialize(klass)
        @klass = klass
    end
    def process(request, response)
        req = StringIO.new(request.body)
        controller = @klass.run(req, request.params)
        response.start(controller.status) do |head,out|
            controller.headers.each do |k, v|
                [*v].each do |vi|
                    head[k] = vi
                end
            end
            out << controller.body
        end
    end
end
