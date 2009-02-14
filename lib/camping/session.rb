# == About camping/session.rb
# TODO: Clean everything up. Lots of just plain wrong stuff in here.
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
require 'openssl'

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
    DIGEST = OpenSSL::Digest::SHA1.new
    # This <tt>service</tt> method, when mixed into controllers, intercepts requests
    # and wraps them with code to start and close the session.  If a session isn't found
    # in the cookie it is created.  The <tt>@state</tt> variable is set and if it changes,
    # it is saved back into the cookie.
    def service(*a)
      @session_blob = @input.camping_blob || @cookies.camping_blob
      @session_hash = @input.camping_hash || @cookies.camping_hash
      decoded_blob, data = '', {}
      begin
        if @session_blob && @session_hash && secure_blob_hasher(@session_blob) == @session_hash
          decoded_blob = Base64.decode64(@session_blob)
          data = Marshal.restore(decoded_blob)
        end

        app = C.name
        @state = (data[app] ||= Camping::H[])
        hash_before = decoded_blob.hash
        return super(*a)
      ensure
        data[app] = @state
        decoded_blob = Marshal.dump(data)
        unless hash_before == decoded_blob.hash
          @session_blob = Base64.encode64(decoded_blob).gsub("\n", '').strip
          @session_hash = secure_blob_hasher(@session_blob)
          raise "The session contains to much data" if @session_blob.length > 4096
          @cookies.camping_blob = @session_blob
          @cookies.camping_hash = @session_hash
        end
      end
    end
    
    def secure_blob_hasher(data)
      OpenSSL::HMAC.hexdigest(DIGEST, state_secret, "#{@env.REMOTE_ADDR}#{data}")
    end
    
    def state_secret; [__FILE__, File.mtime(__FILE__)].join(":") end
end
end
