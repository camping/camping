#!/usr/bin/env ruby

require "rubygems"
require "camping"

Camping.goes :Sessions
require 'camping/session'

module Sessions
  include Camping::Session
  module Controllers
    class One < R('/')
      def get
        @state = C::H['one',rand(100)]
        puts "1:" + @state.inspect
        redirect R(Two)
      end
    end

    class Two < R('/steptwo')
      def get
        @state['two'] = "This is in two"
        puts "2:" + @state.inspect
        redirect R(Three)
      end
    end
    
    class Three < R('/stepthree')
      def get
        @state['three'] = "This is in three"
        puts "3:" + @state.inspect
        return "Accumulated state across redirects: #{@state.inspect}"
        redirect R(Three)
      end
    end
  end
end

