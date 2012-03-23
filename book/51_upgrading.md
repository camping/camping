# Appendix I: Upgrade Notes

This document includes everything needed in order to *upgrade* your
applications. If you're looking for all the new features in a version, please
have a look at the CHANGELOG in the Camping source.


##From 2.0 to 2.1
###Options

In Camping 2.1 there is now a built-in way to store options and settings. If
you use cookie session, it means that you'll now have to change to:

    module Nuts
      set :secret, "Very secret text, which no-one else should know!"
      include Camping::Session
    end


##From 1.5 to 2.0
###Rack

The biggest change in 2.0 is that it now uses [Rack](http://rack.rubyforge.org/)
internally. This means that you'll now have to deploy Camping differently, but
hopefully more easily too. Now every Camping application is also a Rack
application, so simply check out the documentation to the server of your
choice.

###`require 'camping/db'`

In earlier versions of Camping, you loaded database support by:

    require 'camping/db'
  
Actually, this loaded a very thin layer on top of ActiveRecord, and in the
future we want to experiment with other libraries. Therefore you should now
simply remove the line, and instead just inherit from Base right away. This
also means you'll have to place your migrations *after* the models.

We also encourage you to use <tt>Model.table_name</tt> instead of
<tt>:appname_model</tt>, just to make sure it's named correctly.

    ## Don't require anything:
    # require 'camping/db'
    
    module Nuts::Models
      ## Just inherit Base:
      class Page < Base; end
      
      ## Migrations have to come *after* the models:
      class CreateTheBasics < V 0.1
        def self.up
          create_table Page.table_name do |t|
            ...
          end
        end
        
        def self.down
          drop_table Page.table_name
        end
      end
    end

###Cookie Sessions

Camping 2.0 now uses a cookie-based session system, which means you now longer
need a database in order to use sessions. The disadvantage of this is that
you are restricted to only around 4k of data. See below for the changes
required, and see Camping::Session more details.

    module Nuts
      ## Include Camping::Session as before:
      include Camping::Session
      
      ## But also define a secret:
      secret "Very secret text, which no-one else should know!"
    end

    def Nuts.create
      ## And remove the following line:
      # Camping::Models::Session.create_schema
    end
  
###Error handling

Camping now uses three methods in order to handle errors. These replaces the
old classes NotFound and ServerError.

* Camping::Base#r404 is called when a route can't be found.
* Camping::Base#r501 is called when a route is found, but doesn't respond to 
  the method.
* Camping::Base#r500 is called when an error happens.

You can override these in your application:

    module Nuts
      def r404(path)
        "Sorry, but I can't find #{path}."
      end
      
      def r501(method)
        "Sorry, but I can't respond to #{method}."
      end
      
      def r500(klass, method, ex)
        "Sorry, but #{klass}##{method} failed with #{ex}."
      end
    end
  
It should be noted that this might change in the future.
