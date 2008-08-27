class MissingLibrary < Exception #:nodoc: all
end
begin
    require 'markaby'
rescue LoadError => e
    raise MissingLibrary, "Markaby could not be loaded (is it installed?): #{e.message}"
end

$MAB_CODE = %{
  # The Mab class wraps Markaby, allowing it to run methods from Camping::Views
  # and also to replace :href, :action and :src attributes in tags by prefixing the root
  # path.
  class Mab < Markaby::Builder
    include Views
    def tag!(*g,&b)
      h=g[-1]
      [:href,:action,:src].map{|a|(h[a]&&=self/h[a])rescue 0}
      super
    end
  end
}

Camping::S.sub! /autoload\s*:Mab\s*,\s*['"]camping\/mab['"]/, $MAB_CODE
Camping::Apps.each do |c|
  c.module_eval $MAB_CODE
end
