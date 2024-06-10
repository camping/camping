# == About camping.rb
#
# Camping comes with two versions of its source code.  The code contained in
# lib/camping.rb is compressed, stripped of whitespace, using compact algorithms
# to keep it tight.  The unspoken rule is that camping.rb should be flowed with
# no more than 80 characters per line and must not exceed four kilobytes.
#
# On the other hand, lib/camping-unabridged.rb contains the same code, laid out
# nicely with piles of documentation everywhere. This documentation is entirely
# generated from lib/camping-unabridged.rb using RDoc and our "flipbook" template
# found in the extras directory of any camping distribution.
require "cam\ping/loads"

$LOADED_FEATURES << "camping.rb"
E ||= "content-type"
Z ||= "text/html"

class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).define_method(m,&b)
  end
end

# If you're new to Camping, you should probably start by reading the first
# chapters of {The Camping Book}[file:book/01_introduction.html#toc].
#
# Okay. So, the important thing to remember is that <tt>Camping.goes :Nuts</tt>
# copies the Camping module into Nuts. This means that you should never use
# any of these methods/classes on the Camping module, but rather on your own
# app. Here's a short explanation on how Camping is organized:
#
# * Camping::Controllers is where your controllers live.
# * Camping::Models is where your models live.
# * Camping::Views is where your views live.
# * Camping::Base is a module which is included in all your controllers.
# * Camping::Helpers is a module with useful helpers, both for the controllers
#   and the views. You should fill this up with your own helpers.
#
# Camping also ships with:
#
# * Camping::Session adds states to your app.
# * Camping::Server starts up your app in development.
# * Camping::Reloader automatically reloads your apps when a file has changed.
#
# More importantly, Camping also installs The Camping Server,
# please see Camping::Server.
module Camping
  C = self
  S = IO.read(__FILE__) rescue nil
  P = "<h1>Cam\ping Problem!</h1><h2>%s</h2>"
  U = Rack::Utils
  Apps = [] # Our array of Apps
  SK = "camping" #Key for r.session
  G = [] # Our array of Gear

  # An object-like Hash.
  # All Camping query string and cookie variables are loaded as this.
  #
  # To access the query string, for instance, use the <tt>@input</tt> variable.
  #
  #   module Blog::Controllers
  #     class Index < R '/'
  #       def get
  #         if (page = @input.page.to_i) > 0
  #           page -= 1
  #         end
  #         @posts = Post.all, :offset => page * 20, :limit => 20
  #         render :index
  #       end
  #     end
  #   end
  #
  # In the above example if you visit <tt>/?page=2</tt>, you'll get the second
  # page of twenty posts.  You can also use <tt>@input['page']</tt> to get the
  # value for the <tt>page</tt> query variable.
  class H < Hash
    # Gets or sets keys in the hash.
    #
    #   @cookies.my_favorite = :macadamian
    #   @cookies.my_favorite
    #   => :macadamian
    #
    def method_missing(m,*a)
      m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m.to_s]:super
    end
    undef id, type if ?? == 63
  end

  O=H.new;O[:url_prefix]="" # Our Hash of Options

  class Cookies < H
    attr_accessor :_p
    #
    # Cookies that are set at this response
    def _n; @n ||= {} end

    alias _s []=

    def set(k, v, o = {})
      _s(j=k.to_s, v)
      _n[j] = {:value => v, :path => _p}.update(o)
    end

    def []=(k, v)
      set k, v, v.is_a?(Hash) ? v : {}
    end
  end

  # Helpers contains methods available in your controllers and views. You may
  # add methods of your own to this module, including many helper methods from
  # Rails. This is analogous to Rails' <tt>ApplicationHelper</tt> module.
  #
  # == Using ActionPack Helpers
  #
  # If you'd like to include helpers from Rails' modules, you'll need to look
  # up the helper module in the Rails documentation at http://api.rubyonrails.org/.
  #
  # For example, if you look up the <tt>ActionView::Helpers::FormTagHelper</tt>
  # class, you'll find that it's loaded from the <tt>action_view/helpers/form_tag_helper.rb</tt>
  # file. You'll need to have the ActionPack gem installed for this to work.
  #
  # A helper often depends on other helpers, so you would have to look up
  # the dependencies too. <tt>FormTagHelper</tt> for instance required the
  # <tt>content_tag</tt> provided by <tt>TagHelper</tt>.
  #
  #   require 'action_view/helpers/form_tag_helper'
  #
  #   module Nuts::Helpers
  #     include ActionView::Helpers::TagHelper
  #     include ActionView::Helpers::FormTagHelper
  #   end
  #
  # == Return a response immediately
  # If you need to return a response inside a helper, you can use <tt>throw :halt</tt>.
  #
  #   module Nuts::Helpers
  #     def requires_login!
  #       unless @state.user_id
  #         redirect Login
  #         throw :halt
  #       end
  #     end
  #   end
  #
  #   module Nuts::Controllers
  #     class Admin
  #       def get
  #         requires_login!
  #         "Never gets here unless you're logged in"
  #       end
  #     end
  #   end
  module Helpers
    # From inside your controllers and views, you will often need to figure out
    # the route used to get to a certain controller +c+. Pass the controller
    # class and any arguments into the R method, a string containing the route
    # will be returned to you.
    #
    # Assuming you have a specific route in an edit controller:
    #
    #   class Edit < R '/edit/(\d+)'
    #
    # A specific route to the Edit controller can be built with:
    #
    #   R(Edit, 1)
    #
    # Which outputs: <tt>/edit/1</tt>.
    #
    # If a controller has many routes, the route will be selected if it is the
    # first in the routing list to have the right number of arguments.
    #
    # == Using R in the View
    #
    # Keep in mind that this route doesn't include the root path. You will
    # need to use <tt>/</tt> (the slash method above) in your controllers.
    # Or, go ahead and use the Helpers#URL method to build a complete URL for
    # a route.
    #
    # However, in your views, the :href, :src and :action attributes
    # automatically pass through the slash method, so you are encouraged to
    # use <tt>R</tt> or <tt>URL</tt> in your views.
    #
    #  module Nuts::Views
    #    def menu
    #      div.menu! do
    #        a 'Home', :href => URL()
    #        a 'Profile', :href => "/profile"
    #        a 'Logout', :href => R(Logout)
    #        a 'Google', :href => 'http://google.com'
    #      end
    #    end
    #  end
    #
    # Let's say the above example takes place inside an application mounted at
    # <tt>http://localhost:3301/frodo</tt> and that a controller named
    # <tt>Logout</tt> is assigned to route <tt>/logout</tt>.
    # The HTML will come out as:
    #
    #   <div id="menu">
    #     <a href="http://localhost:3301/frodo/">Home</a>
    #     <a href="/frodo/profile">Profile</a>
    #     <a href="/frodo/logout">Logout</a>
    #     <a href="http://google.com">Google</a>
    #   </div>
    #
    def R(c,*g)
      p,h=/\(.+?\)/,g.grep(Hash)
      g-=h
      raise "bad route" if !u = c.urls.find{|x|
        break x if x.scan(p).size == g.size &&
          /^#{x}\/?$/ =~ (x=g.inject(x){|x,a|
            x.sub p,U.escape((a.to_param rescue a))}.gsub(CampTools.descape){$1})
      }
      h.any?? u+"?"+U.build_query(h[0]) : u
    end

    # Simply builds a complete path from a path +p+ within the app.  If your
    # application is mounted at <tt>/blog</tt>:
    #
    #   self / "/view/1"    #=> "/blog/view/1"
    #   self / "styles.css" #=> "styles.css"
    #   self / R(Edit, 1)   #=> "/blog/edit/1"
    #
    def /(p)
      p[0] == ?/ ? (@root + @url_prefix.dup.prepend("/").chop + p) : p
    end

    # Builds a URL route to a controller or a path, returning a URI object.
    # This way you'll get the hostname and the port number, a complete URL.
    #
    # You can use this to grab URLs for controllers using the R-style syntax.
    # So, if your application is mounted at <tt>http://test.ing/blog/</tt>
    # and you have a View controller which routes as <tt>R '/view/(\d+)'</tt>:
    #
    #   URL(View, @post.id)    #=> #<URL:http://test.ing/blog/view/12>
    #
    # Or you can use the direct path:
    #
    #   self.URL               #=> #<URL:http://test.ing/blog/>
    #   self.URL + "view/12"   #=> #<URL:http://test.ing/blog/view/12>
    #   URL("/view/12")        #=> #<URL:http://test.ing/blog/view/12>
    #
    # It's okay to pass URL strings through this method as well:
    #
    #   URL("http://google.com")  #=> #<URL:http://google.com>
    #
    # Any string which doesn't begin with a slash will pass through
    # unscathed.
    def URL c='/',*a
      c = R(c, *a) if c.respond_to? :urls
      c = self/c
      c = @request.url[/.{8,}?(?=\/|$)/]+c if c[0]==?/ #/
      URI(c)
    end

    # Just a helper to tell you the App Name
    # During the instantiation of the app, "Camping" is replaced with the Apps namespace.
    def app_name;"Camping"end

  end

  # Camping::Base is built into each controller by way of the generic routing
  # class Camping::R. In some ways, this class is trying to do too much, but
  # it saves code for all the glue to stay in one place. Forgivable,
  # considering that it's only really a handful of methods and accessors.
  #
  # Everything in this module is accessible inside your controllers.
  module Base
    attr_accessor :env, :request, :root, :input, :cookies, :state,
                  :status, :headers, :body, :url_prefix

    T = {}
    L = :layout

    # Finds a template, returning either:
    #
    #   false             # => Could not find template
    #   true              # => Found template in Views
    #   instance of Tilt  # => Found template in a file
    def lookup(n)
      T.fetch(n.to_sym) { |k|
        # Find a view defined in the Views module first
        t = Views.method_defined?(k) ||
          # Find inline templates (delimited by @@), and then put it in a new Template and return that.
          # `:_t` is the options key for inline templates. Inline templates are added in `Camping#goes`.
          (t = O[:_t].keys.grep(/^#{n}\./)[0]and Template[t].new{O[:_t][t]}) ||

          # Find templates in a views directory, and return the first view that matches the symbol provided.
          # Then pipe that template file into Template, which is just Tilt.
          (f = Dir[[O[:views] || "views", "#{n}.*"]*'/'][0]) &&

          # Grab any settings set for the template files, as set by their filename extension
          # and add that to the options of Template (Tilt), or an empty Hash
          # What does adding settings for a template look like? :
          #   module Nuts
          #     def r404(path)
          #       @path = path
          #       render :not_found
          #     end
          #   end
          Template.new(f, O[f[/\.(\w+)$/, 1].to_sym] || {})

        O[:dynamic_templates] ? t : T[k] = t
      }
    end

    # Display a view, calling it by its method name +v+. If a <tt>layout</tt>
    # method is found in Camping::Views, it will be used to wrap the HTML.
    #
    #   module Nuts::Controllers
    #     class Show
    #       def get
    #         @posts = Post.find :all
    #         render :index
    #       end
    #     end
    #   end
    #
    def render(v, *a, &b)
      if t = lookup(v)
        # Has this controller rendered before?
        r = @_r
        # Set @_r to truthy value
        @_r = (o = Hash === a[-1] ? a.pop : {})
        s = (t == true) ? mab { send(v, *a, &b) } : t.render(self, o[:locals] || {}, &b)
        s = render(L, o.merge(L => false)) { s } if o[L] or o[L].nil? && lookup(L) && !r && v.to_s[0] != ?_
        s
      else
        raise "no template: #{v}"
      end
    end

    # You can directly return HTML from your controller for quick debugging
    # by calling this method and passing some Markaby to it.
    #
    #   module Nuts::Controllers
    #     class Info
    #       def get; mab{ code @headers.inspect } end
    #     end
    #   end
    #
    # You can also pass true to use the :layout HTML wrapping method
    def mab(&b)
      extend Mab
      mab(&b)
    end

    # A quick means of setting this controller's status, body and headers
    # based on a Rack response:
    #
    #   r(302, 'Location' => self / "/view/12", '')
    #   r(*another_app.call(@env))
    #
    # You can also switch the body and the header if you want:
    #
    #   r(404, "Could not find page")
    #
    # See also: #r404, #r500 and #r501
    def r(s, b, h = {})
      b, h = h, b if Hash === b
      @status = s
      @headers.merge!(h)
      @body = b
    end

    # Formulate a redirect response: a 302 status with <tt>Location</tt> header
    # and a blank body. Uses Helpers#URL to build the location from a
    # controller route or path.
    #
    # So, given a root of <tt>http://localhost:3301/articles</tt>:
    #
    #   redirect "view/12"  # redirects to "//localhost:3301/articles/view/12"
    #   redirect View, 12   # redirects to "//localhost:3301/articles/view/12"
    #
    # <b>NOTE:</b> This method doesn't magically exit your methods and redirect.
    # You'll need to <tt>return redirect(...)</tt> if this isn't the last statement
    # in your code, or <tt>throw :halt</tt> if it's in a helper.
    #
    # See: Controllers
    def redirect(*a)
      r(302,'','Location'=>URL(*a).to_s)
    end

    # Called when a controller was not found. You can override this if you
    # want to customize the error page:
    #
    #   module Nuts
    #     def r404(path)
    #       @path = path
    #       render :not_found
    #     end
    #   end
    def r404(p)
      P % "#{p} not found"
    end

    # Called when an exception is raised. However, if there is a parse error
    # in Camping or in your application's source code, it will not be caught.
    #
    # +k+ is the controller class, +m+ is the request method (GET, POST, etc.)
    # and +e+ is the Exception which can be mined for useful info.
    #
    # By default this simply re-raises the error so a Rack middleware can
    # handle it, but you are free to override it here:
    #
    #   module Nuts
    #     def r500(klass, method, exception)
    #       send_email_alert(klass, method, exception)
    #       render :server_error
    #     end
    #   end
    def r500(k,m,e)
      raise e
    end

    # Called if an undefined method is called on a controller, along with the
    # request method +m+ (GET, POST, etc.)
    def r501(m)
      P % "#{m.upcase} not implemented"
    end

    # Serves the string +c+ with the MIME type of the filename +p+.
    # Defaults to text/html.
    def serve(p, c)
      t = Rack::Mime.mime_type(p[/\..*$/], Z) and @headers[E] = t
      c
    end

    # Turn a controller into a Rack response. This is designed to be used to
    # pipe controllers into the <tt>r</tt> method. A great way to forward your
    # requests!
    #
    #   class Read < '/(\d+)'
    #     def get(id)
    #       Post.find(id)
    #     rescue
    #       r *Blog.get(:NotFound, @headers.REQUEST_URI)
    #     end
    #   end
    def to_a
      @env['rack.session'][SK] = Hash[@state]
      r = Rack::Response.new(@body, @status, @headers)
      @cookies._n.each do |k, v|
        r.set_cookie(k, v)
      end
      r.to_a
    end

    # initialize
    # Turns a camping controller class into an object and sets up
    # the environment with input, cookies, state, headers, etc...
    def initialize(env, m, p) #:nodoc:
      r = @request = Rack::Request.new(@env = env)
      @root, @input, @cookies, @state,
      @headers, @status, @method, @url_prefix =
      r.script_name.sub(/\/$/,''), n(r.params),
      Cookies[r.cookies], H[r.session[SK]||{}],
      {E=>Z}, m =~ /r(\d+)/ ? $1.to_i : 200, m, p
      @cookies._p = self/"/"
    end

    # n method
    # accepts parameters and converts them to a hash.
    # helper method for initialize
    def n(h) # :nodoc:
      if Hash === h
        h.inject(H[]) { |m, (k, v)|
          m[k] = n(v)
          m
        }
      else
        h
      end
    end

    # All requests pass through this method before going to the controller.
    # Some magic in Camping can be performed by overriding this method.
    def service(*a)
      r = catch(:halt){send(@method, *a)}
      @body ||= r
      self
    end
  end

  # Controllers receive the requests and send a response back to the client.
  # A controller is simply a class which must implement the HTTP methods it
  # wants to accept:
  #
  #   module Nuts::Controllers
  #     class Index
  #       def get
  #         "Hello World"
  #       end
  #     end
  #
  #     class Posts
  #       def post
  #         Post.create(@input)
  #         redirect Index
  #       end
  #     end
  #   end
  #
  # == Defining a controller
  #
  # There are two ways to define controllers:
  #
  # 1. Define a class and let Camping figure out the route.
  # 2. Add the route explicitly using R.
  #
  # If you don't use R, Camping will first split the controller name up by
  # words (HelloWorld => Hello and World).
  #
  # After that, it will do the following:
  #
  # * Replace Index with /
  # * Replace X with ([^/]+)
  # * Replace N with (\\\d+)
  # * Turn everything else into lowercase
  # * Join the words with slashes
  #
  #--
  # NB!  N will actually be replaced with (\d+), but it needs to be escaped
  # here in order to work correctly with RDoc.
  #++
  #
  # Here are a few examples:
  #
  #   Index   # => /
  #   PostN   # => /post/(\d+)
  #   PageX   # => /page/([^/]+)
  #   Pages   # => /pages
  #
  # == The request
  #
  # The following variables aid in describing a request:
  #
  # * @env contains the environment as defined in https://github.com/rack/rack/blob/main/SPEC.rdoc
  # * @request is Rack::Request.new(@env)
  # * @root is the path where the app is mounted
  # * @cookies is a hash with the cookies sent by the client
  # * @state is a hash with the sessions (see Camping::Session)
  # * @method is the HTTP method in lowercase
  # * @url_prefix is the set prefix of the route matched by your controller
  #
  # == The response
  #
  # You can change these variables to your needs:
  #
  # * @status is the HTTP status (defaults to 200)
  # * @headers is a hash with the headers
  # * @body is the body (a string or something which responds to #each)
  # * Any changes in @cookies and @state will also be sent to the client
  #
  # If you haven't set @body, it will use the return value of the method:
  #
  #   module Nuts::Controllers
  #     class Index < Camper
  #       def get
  #         "This is the body"
  #       end
  #     end
  #
  #     class Posts < Camper
  #       def get
  #         @body = "Hello World!"
  #         "This is ignored"
  #       end
  #     end
  #   end
  module Controllers
    @r = []

    # An empty controller class that our other Classes inherit from.
    # Camper is used by the R method internally.
    class Camper end

    class << self

      # Add routes to a controller class by piling them into the R method.
      #
      # The route is a regexp which will match the request path. Anything
      # enclosed in parenthesis will be sent to the method as arguments.
      #
      #   module Camping::Controllers
      #     class Edit < R '/edit/(\d+)', '/new'
      #       def get(id)
      #         if id   # edit
      #         else    # new
      #         end
      #       end
      #     end
      #   end
      #
      # Routes may be inherited using the R command as well. In this case you'll
      # pass the ancestor Controller as the first argument to R.
      #
      #   module Camping::Controllers
      #     class Post < R Edit, '/edit/(\d+)', '/new'
      #       def get(id)
      #         if id   # edit
      #         else    # new
      #         end
      #       end
      #     end
      #   end
      #
      def R *u
        r,uf=@r,u.first
        Class.new((uf.is_a?(Class) && (uf.ancestors.include?(Camper))) ? u.shift : Camper) {
          meta_def(:urls){u}
          meta_def(:inherited){|x|r<< x}
        }
      end

      # A Helper method to map and return the actual routes of our controllers
      def v
        @r.map(&:urls)
      end

      # Dispatch routes to controller classes.
      # For each class, routes are checked for a match based on their order in the routing list
      # given to Controllers::R. If no routes were given, the dispatcher uses a slash followed
      # by the lowercased name of the controller.
      #
      # Controllers are searched in this order:
      #
      # * Classes without routes, since they refer to a very specific URL.
      # * Classes with routes are searched in order of their creation.
      #
      # So, define your catch-all controllers last.
      def D(p, m, e)
        p = '/' if !p || !p[0]
        a=O[:_t].find{|n,_|n==p} and return [I, :serve, *a]
        @r.map { |k|
          k.urls.map { |x|
            return (k.method_defined?(m)) ?
              [k, m, *$~[1..-1].map{|x|U.unescape(x)}] : [I, 'r501', m] if p =~ /^#{x}\/?$/
          }
        }
        [I, 'r404', p]
      end

      # A lambda to avoid internal controller route
      A = -> (c, u, p) {
        d = p.dup
        d.chop! if u == ''
        u.prepend("/"+d) if !["I"].include? c.to_s
        if c.to_s == "Index"
          while d[-1] == "/"; d.chop! end
          u.prepend("/"+d)
        end
        u
      }

      N = H.new { |_,x| x.downcase }.merge! "N" => '(\d+)', "X" => '([^/]+)', "Index" => ''
      # The route maker, called by Camping internally.
      #
      # Still, it's worth know what this method does. Since Ruby doesn't keep
      # track of class creation order, we're keeping an internal list of the
      # controllers which inherit from R(). This method goes through and adds
      # all the remaining routes to the beginning of the list and ensures all
      # the controllers have the right mixins.
      #
      # Anyway, if you are calling the URI dispatcher from outside of a
      # Camping server, you'll definitely need to call this to set things up.
      # Don't call it too early though - any controllers added after this
      # method was called won't work properly.
      def M(p)
        def M(p) #:nodoc:
        end
        # TODO: Refactor this to make it less convoluted around making urls.
        constants.filter {|c| c.to_s != 'Camper'}.map { |c|
          k = const_get(c)
          k.include(C,X,Base,Helpers,Models)
          @r=[k]+@r if @r-[k]==@r
          mu = false # Should we make urls?
          ka = k.ancestors
          # This complicated code checks the ancestor chain of a controller to see it has it's own urls,
          # or if it's urls are from one of it's ancestors. ancestor URLs need to be discarded.
          if (k.respond_to?(:urls) && ka[1].respond_to?(:urls)) && (k.urls == ka[1].urls)
            mu = true unless ka[1].name == nil
          end
          k.meta_def(:urls){[A.(k,"#{c.to_s.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}", p)]} if (!k.respond_to?(:urls) || mu == true)
        }
      end
    end

    # Internal controller with no route. Used to show internal messages.
    I = R()
  end
  X = Controllers

  class << self

    # Create method to setup routes for Camping upon reload.
    def make_camp
      X.M prx
      Apps.map(&:make_camp)
    end

    # Helper method for getting routes from the controllers.
    # helps Camping::Server map routes to multiple apps.
    # Usage:
    #
    #   Nuts.routes # returns routes for Nuts
    #   Camping.routes
    #
    def routes
      (Apps.map(&:routes)<<X.v).flatten
    end

    # An internal method used to return the current app's url_prefix.
    # the prefix is processed to make sure that it's not all wonky. excessive
    # trailing and leading slashes are removed. A trailing slash is added.
    # @return [String] A reference to the URL response
    def prx
      @_prx ||= CampTools.normalize_slashes(O[:url_prefix])
    end

    # Ruby web servers use this method to enter the Camping realm. The +e+
    # argument is the environment variables hash as per the Rack specification.
    # Array with [status, headers, body] is expected at the output.
    #
    # See: https://github.com/rack/rack/blob/main/SPEC.rdoc
    # @param [Array] A rack response
    # @return [Array] A rack response
    def call(e)
      k,m,*a=X.D e["PATH_INFO"],e['REQUEST_METHOD'].downcase,e
      k.new(e,m,prx).service(*a).to_a
    rescue
      r500(:I, k, m, $!, :env => e).to_a
    end

    # The Camping scriptable dispatcher. Any unhandled method call to the app
    # module will be sent to a controller class, specified as an argument.
    #
    #   Blog.get(:Index)
    #   #=> #<Blog::Controllers::Index ... >
    #
    # The controller object contains all the @cookies, @body, @headers, etc.
    # formulated by the response.
    #
    # You can also feed environment variables and query variables as a hash,
    # the final argument.
    #
    #   Blog.post(:Login, :input => {'username' => 'admin', 'password' => 'camping'})
    #   #=> #<Blog::Controllers::Login @user=... >
    #
    #   Blog.get(:Info, :env => {'HTTP_HOST' => 'wagon'})
    #   #=> #<Blog::Controllers::Info @headers={'HTTP_HOST'=>'wagon'} ...>
    #
    def method_missing(m, c, *a)
      h = Hash === a[-1] ? a.pop : {}
      e = H[Rack::MockRequest.env_for('',h.delete(:env)||{})]
      k = X.const_get(c).new(e,m.to_s,prx)
   #  rescue => error # : wrong number of arguments
			# Campguide::make_sense error.message
      h.each { |i, v| k.send("#{i}=", v) }
      k.service(*a)
    end

    # Injects a middleware:
    #
    #   module Blog
    #     use Rack::MethodOverride
    #     use Rack::Session::Memcache, :key => "session"
    #   end
    #
    # This piece of code feels a bit confusing, but let's walk through it.
    # Rack apps all implement a Call method. This is how Ruby web servers
    # call the app, or code that you've set up. In our case, our camping
    # apps.
    #
    # The Use method is setting up a new middleware, it shifts the first
    # argument supplied to Use, which should be the Middleware name, then
    # initializes it. That's your new middleware. Rack based middleware accept
    # a single argument to their initialize methods, which is an app. Optionally
    # settings and a block are supplied.
    #
    # So a new app is made, and its settings are supplied, then immediately
    # sent to the new middleware we just added. But the cool part is where we
    # call meta_def. meta_def takes a symbol and a block, and defines a class
    # method into the current context. Our current context is our camping app.
    # So when we call it below we're redefining the call method to call the new
    # middleware that we just added. The `m` variable below represents our
    # newly created middleware object, that we initialized with our old app. and
    # because we're defining a new call method with a block, it's captured in
    # that block.
    #
    # This creates a sequence of middleware that isn't recorded anywhere, but
    # nonetheless is set up in the proper order and called in the proper order.
    def use(*a, &b)
      m = a.shift.new(method(:call), *a, &b)
      meta_def(:call) { |e| m.call(e) }
      m
    end

    # Add gear to your app:
    #
    #   module Blog
    #     pack Camping::Gear::CSRF
    #   end
    #
    # Why have plugins in the first place if we can just include and extend our
    # modules and classes directly? To perform setup actions!
    #
    # Sometimes you might have ClassMethods that you want to modify Camping with,
    # This gives us a way to do that. In your gear:
    #
    #   module MyGear
    #     module ClassMethods
    #       # Define Class Methods here
    #     end
    #     def self.included(mod)
    #       mod.extend(ClassMethods)
    #     end
    #   end
    #
    # Optionally a plugin may have a setup method and a ClassMethods module:
    #
    #   module MyGear
    #     def self.setup(s)
    #       # Perform setup actions
    #     end
    #     module ClassMethods
    #       # Define Class Methods here
    #     end
    #   end
    #
    # Camping gear can also provide Helper methods to our controllers:
    #
    #   module MyGear
    #     module HelperMethods
    #       # Define Helper Methods here
    #     end
    #
    #     # This is plumbing in our Gear to add our Helper methods.
    #     class << self
    #       def included(mod)
    #         mod::Helpers.include(HelperMethods)
    #       end
    #     end
    #   end
    #
    # Helper methods are available in our controllers.
    def pack(*a, &b)
      G << g = a.shift
      include g
      g.setup(self, *a, &b) # if g.respond_to?(:setup) # Force all gear to have a setup function
    end

    # Helper method to list gear
    def gear
      G
    end

    # A hash where you can set different settings.
    def options
      O
    end

    # Shortcut for setting options:
    #
    #   module Blog
    #     set :secret, "Hello!"
    #   end
    def set(k, v)
      O[k] = v
    end

    # When you are running multiple applications, you may want to create
    # independent modules for each Camping application. Camping::goes
    # defines a top level constant with the whole MVC rack inside:
    #
    #   require 'camping'
    #   Camping.goes :Nuts
    #
    #   module Nuts::Controllers; ... end
    #   module Nuts::Models;      ... end
    #   module Nuts::Views;       ... end
    #
    # Additionally, you can pass a Binding as the second parameter,
    # which enables you to create a Camping-based application within
    # another module.
    #
    # Here's an example of name spacing your web interface and
    # code for a worker process together:
    #
    #   module YourApplication
    #     Camping.goes :Web, binding()
    #     module Web
    #       ...
    #     end
    #     module Worker
    #       ...
    #     end
    #   end
    #
    # All the applications will be available in Camping::Apps.
    #
    # Camping offers a shortcut for adding thin files, and templates to your apps.
    # Add them at the end of the same ruby file that you call `Camping.goes`:
    #
    #   require 'camping'
    #   Camping.goes :Nuts
    #
    #   module Nuts::Controllers; ... end
    #   module Nuts::Models;      ... end
    #   module Nuts::Views;       ... end
    #
    #   __END__
    #
    #   @@ /style.css
    #   * { margin: 0; padding: 0 }
    #
    #   @@ /test.foo
    #   <H1>Hello friends! Nice to meet you.<H1>
    #
    #   @@ index.erb
    #   Hello <%= @world %>
    #
    # Also sets the apps Meta Data. Can be found at O[:_meta]
    #
    # @app:         {String} - The app in question
    # @parent:      {String} -
    # @root:        {String} -
    # @line_number: {Int}    - The line number that the app was declared
    # @file:        {String} - The file location for this
    #
    def goes(m, g=TOPLEVEL_BINDING)

      # setup caller data
      sp = caller[0].split('`')[0].split(":")
      fl, ln = sp[0]+' <Cam\ping App> ', sp[1].to_i

      # Create the app
      Apps << a = eval(S.gsub(/Camping/,m.to_s), g, fl, 1)

      caller[0]=~/:/
      IO.read(a.set:__FILE__,$`)=~/^__END__/ &&
      (b=$'.split(/^@@\s*(.+?)\s*\r?\n/m)).shift rescue nil
      a.set :_t,H[*b||[]]

      # setup parental data
      a.set :_meta, H[file: fl, line_number: ln, parent: self, root: (name != "Cam\ping" ? '/' + CampTools.to_snake(name) : '/')]

      # configure the app?
      C.configure(a)
    end
  end

  # Views is an empty module for storing methods which create HTML. The HTML
  # is described using the Markaby language.
  #
  # == Defining and calling templates
  #
  # Templates are simply Ruby methods with Markaby inside:
  #
  #   module Blog::Views
  #     def index
  #       p "Welcome to my blog"
  #     end
  #
  #     def show
  #       h1 @post.title
  #       self << @post.content
  #     end
  #   end
  #
  # In your controllers you just call <tt>render :template_name</tt> which will
  # invoke the template. The views and controllers will share instance
  # variables (as you can see above).
  #
  # == Using the layout method
  #
  # If your Views module has a <tt>layout</tt> method defined, it will be
  # called with a block which will insert content from your view:
  #
  #   module Blog::Views
  #     def layout
  #       html do
  #         head { title "My Blog "}
  #         body { self << yield }
  #       end
  #     end
  #   end
  module Views; include X, Helpers end

  # Models is an empty Ruby module for housing model classes derived
  # from ActiveRecord::Base. As a shortcut, you may derive from Base
  # which is an alias for ActiveRecord::Base.
  #
  #   module Camping::Models
  #     class Post < Base; belongs_to :user end
  #     class User < Base; has_many :posts end
  #   end
  #
  # == Where Models are Used
  #
  # Models are used in your controller classes. However, if your model class
  # name conflicts with a controller class name, you will need to refer to it
  # using the Models module.
  #
  #   module Camping::Controllers
  #     class Post < R '/post/(\d+)'
  #       def get(post_id)
  #         @post = Models::Post.find post_id
  #         render :index
  #       end
  #     end
  #   end
  #
  # Models cannot be referred from Views at this time.
  module Models
    Helpers.include(X, self)
  end

  autoload :Mab, 'camping/mab'
  autoload :Template, 'camping/template'

  # Load default Gear
  pack Gear::Inspection
  pack Gear::Filters
  pack Gear::Nancy
  pack Gear::Kuddly

  C
end
