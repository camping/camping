require 'irb' 
require 'irb/completion'

module Camping::Server
class Console < Camping::Server::Base
    def start
        ARGV.clear # Avoid passing args to IRB 
        if File.exists? ".irbrc"
            ENV['IRBRC'] = ".irbrc"
        end
        IRB.start
    end
end
end
