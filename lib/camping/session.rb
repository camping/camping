module Camping
  # == Getting Started
  #
  # To get sessions working for your application:
  # 1. <tt>require 'camping/session'</tt>
  # 2. Define a secret (and keep it secret): <tt>set :secret, "SECRET!"</tt>
  # 3. Mixin the module: <tt>include Camping::Session</tt>
  # 4. Throughout your application, use the <tt>@state</tt> var like a hash
  #    to store your application's data.
  #
  #   require 'camping/session'    # 1
  #   
  #   module Nuts
  #     set :secret, "Oh yeah!"    # 2
  #     include Camping::Session   # 3
  #   end
  #
  # == Other backends
  #
  # Camping only ships with session-cookies. However, the <tt>@state</tt>
  # variable is simply a shortcut for <tt>@env['rack.session']</tt>. Therefore
  # you can also use any middleware which sets this variable:
  #
  #   module Nuts
  #     use Rack::Session::Memcache
  #   end
  module Session
    def self.included(app)
      key    = "#{app}.state".downcase
      secret = app.options[:secret] || [__FILE__, File.mtime(__FILE__)].join(":")
      
      app.use Rack::Session::Cookie, :key => key, :secret => secret
    end
  end
end