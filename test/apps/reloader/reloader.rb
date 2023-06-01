require 'camping'

Camping.goes :Reloader

$LOAD_PATH << File.dirname(__FILE__)
require 'reload_me'
