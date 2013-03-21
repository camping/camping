class MissingLibrary < Exception #:nodoc: all
end
begin
  require 'mab'
rescue LoadError => e
  raise MissingLibrary, "Mab could not be loaded (is it installed?): #{e.message}"
end

$MAB_CODE = %q{
  module Mab
    include ::Mab::Mixin::HTML5
    include Views

    alias << text!

    def xhtml(*a, &b)
      warn "xhtml_strict is no longer supported (or an active standard); using HTML5 instead"
      html(*a, &b)
    end

    def xhtml_strict(*a, &b) xhtml(*a, &b) end
    def xhtml_transitional(*a, &b) xhtml(*a, &b) end
    def xhtml_frameset(*a, &b) xhtml(*a, &b) end

    def helpers() self end

    def html(*) doctype!; super end

    def mab_done(tag)
      h=tag._attributes
      [:href,:action,:src].map{|a|h[a]&&=self/h[a]}
    end
  end
}

Camping::S.sub! /autoload\s*:Mab\s*,\s*['"]camping\/mab['"]/, $MAB_CODE
Camping::Apps.each do |c|
  c.module_eval $MAB_CODE
end
