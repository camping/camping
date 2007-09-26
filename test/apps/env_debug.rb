#!/usr/bin/env ruby

begin require "rubygems" rescue LoadError end
require "camping"

Camping.goes :EnvDebug

module EnvDebug
  module Controllers
    class ShowEnv < R '/', '/(.*)'
      def get(extra = nil)
        @extra = extra
        render :show_env
      end
      alias post get
    end
  end

  module Views
    def layout
      html do
        head{ title C }
        body do
          ul do
            li{ a "show env", :href=>R(ShowEnv)}
          end
          p { yield }
        end
      end
    end

    def _print_hash(hash)
      hash.keys.sort.each do |key|
        value = hash[key]
        pre "%30s: %s" % [key.inspect, value.inspect]
      end
    end

    def show_env
      b "extra: #{@extra.inspect}"
      h2 "@status : #{@status.inspect}"
      h2 "@method : #{@method.inspect}"
      h2 "@root : #{@root.inspect}"
      h2 "@env :"
      _print_hash @env
      h2 "@input : "
      _print_hash @input
      h2 "@headers :"
      _print_hash @headers
   end

  end
end

# For CGI
if $0 == __FILE__
  EnvDebug.create if EnvDebug.respond_to? :create
  if ARGV.any?
    require 'camping/fastcgi'
    #Dir.chdir('/var/camping/blog/')
    Camping::FastCGI.start(EnvDebug)
  else
    puts EnvDebug.run
  end
end
