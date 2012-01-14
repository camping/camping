class MissingLibrary < Exception #:nodoc: all
end
begin
  require 'mab'
rescue LoadError => e
  raise MissingLibrary, "Mab could not be loaded (is it installed?): #{e.message}"
end

$MAB_CODE = %{
  module Mab
    include ::Mab::Mixin::HTML5
    include Views

    alias << text!

    def mab_attributes(tag, a)
      h=a.dup
      [:href,:action,:src].map{|a|h[a]&&=self/h[a]}
      h
    end
  end
}

Camping::S.sub! /autoload\s*:Mab\s*,\s*['"]camping\/mab['"]/, $MAB_CODE
Camping::Apps.each do |c|
  c.module_eval $MAB_CODE
end
