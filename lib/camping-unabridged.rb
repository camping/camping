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
%w[uri rack].map { |l| require l }

class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).send(:define_method,m,&b)
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
  Apps = []
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
    undef id, type
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
  # Often the helpers depends on other helpers, so you would have to look up
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
      raise "bad route" unless u = c.urls.find{|x|
        break x if x.scan(p).size == g.size && 
          /^#{x}\/?$/ =~ (x=g.inject(x){|x,a|
            x.sub p,U.escape((a[a.class.primary_key]rescue a))})
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
    def /(p); p[0]==?/?@root+p:p end
    
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
      c = @request.url[/.{8,}?(?=\/)/]+c if c[0]==?/
      URI(c)
    end
  end

  # Camping::Base is built into each controller by way of the generic routing
  # class Camping::R. In some ways, this class is trying to do too much, but
  # it saves code for all the glue to stay in one place. Forgivable,
  # considering that it's only really a handful of methods and accessors.
  #
  # Everything in this module is accessable inside your controllers.
  module Base
    attr_accessor :env, :request, :root, :input, :cookies, :state,
                  :status, :headers, :body

    # Display a view, calling it by its method name +v+.  If a <tt>layout</tt>
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
    def render(v,*a,&b)
      mab(/^_/!~v.to_s){send(v,*a,&b)}
    end

    # You can directly return HTML form your controller for quick debugging
    # by calling this method and pass some Markaby to it.
    # 
    #   module Nuts::Controllers
    #     class Info
    #       def get; mab{ code @headers.inspect } end
    #     end
    #   end
    #
    # You can also pass true to use the :layout HTML wrapping method
    def mab(l=nil,&b)
      m=Mab.new({},self)
      s=m.capture(&b)
      s=m.capture{layout{s}} if l && m.respond_to?(:layout)
      s
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

    # Called when an exception is raised. However,  if there is a parse error
    # in Camping or in your application's source code, it will not be caught.
    #
    # +k+ is the controller class, +m+ is the request method (GET, POST, etc.)
    # and +e+ is the Exception which can be mined for useful info.
    #
    # Be default this simply re-raises the error so a Rack middleware can
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
      @env['rack.session'] = @state
      r = Rack::Response.new(@body, @status, @headers)
      @cookies.each do |k, v|
        next if @old_cookies[k] == v
        v = { :value => v, :path => self / "/" } if String === v
        r.set_cookie(k, v)
      end
      r.to_a
    end
    
    def initialize(env, m) #:nodoc: 
      r = @request = Rack::Request.new(@env = env)
      @root, @input, @cookies, @state,
      @headers, @status, @method =
      r.script_name.sub(/\/$/,''), n(r.params),
      H[@old_cookies = r.cookies], H[r.session],
      {}, m =~ /r(\d+)/ ? $1.to_i : 200, m
    end
    
    def n(h) # :nodoc:
      if Hash === h
        h.inject(H[]) do |m, (k, v)|
          m[k] = n(v)
          m
        end
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
  
  
  # Controllers receive the requests and sends a response back to the client.
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
  # There are two ways to define controllers: Just defining a class and let
  # Camping figure out the route, or add the route explicitly using R.
  # 
  # If you don't use R, Camping will first split the controller name up by
  # words (HelloWorld => Hello and World). Then it would do the following:
  # 
  # * Replace Index with /
  # * Replace X with ([^/]+)
  # * Replace N with (\\\d+)
  # * Everything else turns into lowercase
  # * Join the words with slashes
  #
  #--
  # NB!  N will actually be replaced with (\d+), but it needs to be escaped
  # here in order to work correctly with RDoc.
  #++
  #
  # Here's a few examples:
  # 
  #   Index   # => /
  #   PostN   # => /post/(\d+)
  #   PageX   # => /page/([^/]+)
  #   Pages   # => /pages
  # 
  # == The request
  # 
  # You have these variables which describes the request:
  # 
  # * @env contains the environment as defined in http://rack.rubyforge.org/doc/SPEC.html
  # * @request is Rack::Request.new(@env)
  # * @root is the path where the app is mounted
  # * @cookies is a hash with the cookies sent by the client
  # * @state is a hash with the sessions (see Camping::Session)
  # * @method is the HTTP method in lowercase
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
  #     class Index
  #       def get
  #         "This is the body"
  #       end
  #     end
  #
  #     class Posts
  #       def get
  #         @body = "Hello World!"
  #         "This is ignored"
  #       end
  #     end
  #   end
  module Controllers
    @r = []
    class << self
      # An array containing the various controllers available for dispatch.
      def r #:nodoc:
        @r
      end
      
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
      def R *u
        r=@r
        Class.new {
          meta_def(:urls){u}
          meta_def(:inherited){|x|r<<x}
        }
      end

      # Dispatch routes to controller classes.
      # For each class, routes are checked for a match based on their order in the routing list
      # given to Controllers::R.  If no routes were given, the dispatcher uses a slash followed
      # by the name of the controller lowercased.
      #
      # Controllers are searched in this order:
      #
      # * Classes without routes, since they refer to a very specific URL.
      # * Classes with routes are searched in order of their creation.
      #
      # So, define your catch-all controllers last.
      def D(p, m)
        p = '/' if !p || !p[0]
        r.map { |k|
          k.urls.map { |x|
            return (k.instance_method(m) rescue nil) ?
              [k, m, *$~[1..-1]] : [I, 'r501', m] if p =~ /^#{x}\/?$/
          }
        }
        [I, 'r404', p]
      end

      N = H.new { |_,x| x.downcase }.merge! "N" => '(\d+)', "X" => '([^/]+)', "Index" => ''
      # The route maker, this is called by Camping internally, you shouldn't
      # need to call it. 
      #
      # Still, it's worth know what this method does. Since Ruby doesn't keep
      # track of class creation order, we're keeping an internal list of the
      # controllers which inherit from R(). This method goes through and adds
      # all the remaining routes to the beginning of the list and ensures all
      # the controllers have the right mixins.
      #
      # Anyway, if you are calling the URI dispatcher from outside of a
      # Camping server, you'll definitely need to call this to set things up.
      # Don't call it too early though. Any controllers added after this
      # method is called won't work properly
      def M
        def M #:nodoc:
        end
        constants.map { |c|
          k = const_get(c)
          k.send :include,C,Base,Helpers,Models
          @r=[k]+r if r-[k]==r
          k.meta_def(:urls){["/#{c.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}"]}if !k.respond_to?:urls
        }
      end
    end

    # Internal controller with no route. Used to show internal messages.
    I = R()
  end
  X = Controllers

  class << self
    # When you are running many applications, you may want to create
    # independent modules for each Camping application. Camping::goes
    # defines a toplevel constant with the whole MVC rack inside:
    #
    #   require 'camping'
    #   Camping.goes :Nuts
    #
    #   module Nuts::Controllers; ... end
    #   module Nuts::Models;      ... end
    #   module Nuts::Views;       ... end 
    #
    # All the applications will be available in Camping::Apps.
    def goes(m)
      Apps << eval(S.gsub(/Camping/,m.to_s), TOPLEVEL_BINDING)
    end
    
    # Ruby web servers use this method to enter the Camping realm. The +e+
    # argument is the environment variables hash as per the Rack specification.
    # And array with [status, headers, body] is expected at the output.
    #
    # See: http://rack.rubyforge.org/doc/SPEC.html
    def call(e)
      X.M
      p = e['PATH_INFO'] = U.unescape(e['PATH_INFO'])
      k,m,*a=X.D p,e['REQUEST_METHOD'].downcase
      k.new(e,m).service(*a).to_a
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
      X.M
      h = Hash === a[-1] ? a.pop : {}
      e = H[Rack::MockRequest.env_for('',h.delete(:env)||{})]
      k = X.const_get(c).new(e,m.to_s)
      h.each { |i, v| k.send("#{i}=", v) }
      k.service(*a)
    end
    
    # Injects a middleware:
    #
    #   module Blog
    #     use Rack::MethodOverride
    #     use Rack::Session::Memcache, :key => "session"
    #   end
    def use(*a, &b)
      m = a.shift.new(method(:call), *a, &b)
      meta_def(:call) { |e| m.call(e) }
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
  # Models cannot be referred to in Views at this time.
  module Models
    autoload :Base,'camping/ar'
  end
 
  autoload :Mab, 'camping/mab'
  C
end

