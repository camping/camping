require "dry/inflector"

# Camping Tools is a toolbox for Camping
module Camping
  module Tools
    class << self

      # Normalize Slashes
      # normalizes the leading and trailing slashes of a string to only have a
      # single trailing slash and no leading slashes.
      def normalize_slashes(string)
        f = string.dup
        return "" if f == "" # Short circuit for blank prefixes.
        f.chop!until f[-1] != "/"
        f.slice!(0)until f[0] != "/"
        f << "/"
      end

      alias norms normalize_slashes

      # A Regex to descape escaped characters.
      # used to correct URLs that are escaped using Rack Util's escape function.
      def descape
        /\\(.)/
      end
      
      def inflector
        inin = Dry::Inflector.new
        inin
      end
      
      # to_snake
      # Accepts a string and snake Cases it.
      # Also accepts symbols and coerces them into a string.
      def to_snake(string)
        string = string.to_s if string.class == Symbol
        string.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
      
      def to_camel_case(string)
        cammelled = ""
        to_snake(string).split("_").each do |seq|
          cammelled << seq.capitalize
        end
        cammelled
      end
      
      # Helper method that generates an app name from command line input.
      def app_name_from_input(app_name)
        app_name = :Camp if app_name == nil
        app_name = app_name.to_sym if app_name.class == String
        snake_name = to_snake(app_name)
        camel_name = to_camel_case(snake_name)
        app_name = camel_name.to_sym
        
        {app_name: , snake_name: , camel_name: }
      end

    end
  end
end

# String class extensions
class String
  
  # to_snake
  # Accepts a string and snake Cases it.
  # Also accepts symbols and coerces them into a string.
  #def to_snake(string)
  #  string = string.to_s if string.class == Symbol
  #  string.gsub(/::/, '/').
  #  gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
  #  gsub(/([a-z\d])([A-Z])/,'\1_\2').
  #  tr("-", "_").
  #  downcase
  #end
  
  ## transform app_name to camel Case
  #def to_camel(string)
  #  cammelled = ""
  #  to_snake(string).split("_").each do |seq|
  #    cammelled << seq.capitalize
  #  end
  #  cammelled
  #end

end

CampTools = Camping::Tools 
