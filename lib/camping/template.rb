class MissingLibrary < Exception #:nodoc: all
end
begin
    require 'tilt'
rescue LoadError => e
    raise MissingLibrary, "Tilt could not be loaded (is it installed?): #{e.message}"
end

$TILT_CODE = %{
  Template = Tilt
  include Tilt::CompileSite unless self.options[:dynamic_templates]
}

Camping::S.sub! /autoload\s*:Template\s*,\s*['"]camping\/template['"]/, $TILT_CODE
Camping::Apps.each do |c|
  c.module_eval $TILT_CODE
end
