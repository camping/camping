require 'fcgi'

module Camping
class FastCGI
    def initialize
        @mounts = {}
    end
    def mount(dir, app)
        dir.gsub!(/\/{2,}/, '/')
        dir.gsub!(/\/+$/, '')
        @mounts[dir] = app
    end
    def match(path, mount)
        m = path.match(/^#{Regexp::quote mount}(\/|$)/)
        if m: m.end(0)
        else  -1
        end
    end
    def start
        FCGI.each do |req|
            # req.out << app.run(req.in, req.env)
            path = req.env['SCRIPT_NAME'] + req.env['PATH_INFO']
            dir, app = @mounts.max { |a,b| match(path, a[0]) <=> match(path, b[0]) }
            req.env['SCRIPT_NAME'] = dir
            req.env['PATH_INFO'] = path.gsub(/^#{dir}/, '')
            req.out << app.run(req.in, req.env)
            req.finish
        end
    end
    def self.start(app)
        cf = Camping::FastCGI.new
        cf.mount("/", app)
        cf.start
    end
end
end
