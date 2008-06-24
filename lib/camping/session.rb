# == About camping/session.rb
#
# This file contains two modules which supply basic sessioning to your Camping app.
# Again, we're dealing with a pretty little bit of code: approx. 60 lines.
# 
# * Camping::Models::Session is a module which adds a single <tt>sessions</tt> table
#   to your database.
# * Camping::Session is a module which you will mix into your application (or into
#   specific controllers which require sessions) to supply a <tt>@state</tt> variable
#   you can use in controllers and views.
#
# For a basic tutorial, see the *Getting Started* section of the Camping::Session module.
#require 'camping'
require 'base64'
require 'digest/sha2'

module Camping
# The Camping::Session module is designed to be mixed into your application or into specific
# controllers which require sessions.  This module defines a <tt>service</tt> method which
# intercepts all requests handed to those controllers.
#
# == Getting Started
#
# To get sessions working for your application:
#
# 1. <tt>require 'camping/session'</tt>
# 2. Mixin the module: <tt>module YourApp; include Camping::Session end</tt>
# 3. Define a secret (and keep it secret): <tt>module YourApp; @@state_secret = "SECRET!"; end</tt>
# 4. Throughout your application, use the <tt>@state</tt> var like a hash to store your application's data. 
#
# == A Few Notes
#
# * The session is stored in a cookie. Look in <tt>@cookies.identity</tt>.
# * Session data is only saved if it has changed. 
module Session
    # This <tt>service</tt> method, when mixed into controllers, intercepts requests
    # and wraps them with code to start and close the session.  If a session isn't found
    # in the cookie it is created.  The <tt>@state</tt> variable is set and if it changes,
    # it is saved back into the cookie.
    def service(*a)
      blob, data = '', {}
      begin
        if ![:hash, :blob].detect { |x| !@cookies.include?("camping_#{x}") } &&
            secure_blob_hasher(@cookies.camping_blob) == @cookies.camping_hash
          blob = Base64.decode64(@cookies.camping_blob)
          data = Marshal.restore(blob)
        end

        app = self.class.name.gsub(/^(\w+)::.+$/, '\1')
        @state = (data[app] ||= Camping::H[])
        hash_before = blob.hash
        return super(*a)
      ensure
        data[app] = @state
        blob = Marshal.dump(data)
        unless hash_before == blob.hash
          content = Base64.encode64(blob).gsub("\n", '').strip
          raise "The session contains to much data" if content.length > 4096
          @cookies.camping_blob = content
        else
          content = @cookies.camping_blob
        end
        @cookies.camping_hash = secure_blob_hasher(content)
      end
    end
    
    def secure_blob_hasher(data)
      Digest::SHA256.hexdigest("#{state_secret}#{@env.REMOTE_ADDR}#{@env.HTTP_USER_AGENT}#{data}")
    end
    
    def state_secret; [__FILE__, File.mtime(__FILE__)].join(":") end
end
end
