class MissingLibrary < Exception #:nodoc: all
end
begin
    require 'tilt'
rescue LoadError => e
    raise MissingLibrary, "Tilt could not be loaded (is it installed?): #{e.message}"
end

$TILT_CODE = %{
  Template = Tilt
  include Tilt::CompileSite
}

Camping::S.sub! /autoload\s*:Tilt\s*,\s*['"]camping\/tilt['"]/, $TILT_CODE
Camping::Apps.each do |c|
  c.module_eval $TILT_CODE
end
