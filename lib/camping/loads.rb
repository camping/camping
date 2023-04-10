# loads.rb
# just loads things into camping.rb

# external dependencies
require "uri"
require "rack"
require 'rubygems'
require 'bundler/setup'

# internal stuff
require 'camping/tools'
require 'camping/gear/filters'
require 'camping/gear/nancy'
require 'camping/gear/inspection'
require 'camping/gear/kuddly'

