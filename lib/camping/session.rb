module Camping
  # == Getting Started
  #
  # To get sessions working for your application:
  # 1. <tt>require 'camping/session'</tt>
  # 2. Mixin the module: <tt>include Camping::Session</tt>
  # 3. Define a secret (and keep it secret): <tt>secret "SECRET!"</tt>
  # 4. Throughout your application, use the <tt>@state</tt> var like a hash
  #    to store your application's data.
  #
  #   require 'camping/session'    # 1
  #   
  #   module MyApp
  #     include Camping::Session   # 2
  #     secret "Oh yeah!"          # 3
  #   end
  module Session
    def self.included(app)
      key    = "#{app}.state".downcase
      secret = [__FILE__, File.mtime(__FILE__)].join(":")
      
      app.meta_def(:secret) { |val| secret.replace(val) } 
      app.use Rack::Session::Cookie, :key => key, :secret => secret
    end
  end
end