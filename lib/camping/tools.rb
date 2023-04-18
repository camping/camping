# frozen_string_literal: true

# Camping Tools is a toolbox for Camping
module Camping
  module Tools
    class << self
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
      # used to correct URLs that are escpaed using Rack Util's escape function.
      def descape
        /\\(.)/
      end

    end
  end
end

🏕 = Camping::Tools
CampTools = Camping::Tools
