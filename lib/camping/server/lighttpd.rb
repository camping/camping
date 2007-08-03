require 'rbconfig'

module Camping::Server
class Lighttpd < Camping::Server::Base
    attr_reader :dispatcher, :lighttpd_conf
    def initialize(conf, paths = [])
        super(conf, paths)
        raise unless conf.host && conf.port
    end
    def start
      ruby = File.join(Config::CONFIG['bindir'], Config::CONFIG['RUBY_INSTALL_NAME'])
      @dispatcher =<<SCRIPT
      #!#{ruby}
      require 'rubygems'
      require 'camping/fastcgi'
      Camping::Models::Base.establish_connection(Marshal.load(#{Marshal.dump(conf.database).dump})) 
      Camping::FastCGI.serve("")
SCRIPT
      
      @lighttpd_conf =<<CONF
      server.port                 = #{conf.port}
      server.bind                 = "#{conf.host}"
      server.modules              = ( "mod_fastcgi" )
      server.document-root        = "/dont/need/one" 
      
      #### fastcgi module
      fastcgi.server = ( "/" => ( 
        "localhost" => ( 
          "socket" => "/tmp/camping-blog.socket",
          "bin-path" => "#{conf.dispatcher}",
          "check-local" => "disable",
          "max-procs" => 1 ) ) )
CONF
    end
end
end
