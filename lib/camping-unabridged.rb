# == About camping.rb
#
# Camping comes with two versions of its source code.  The code contained in
# lib/camping.rb is compressed, stripped of whitespace, using compact algorithms
# to keep it tight.  The unspoken rule is that camping.rb should be flowed with
# no more than 80 characters per line and must not exceed four kilobytes.
#
# On the other hand, lib/camping-unabridged.rb contains the same code, laid out
# nicely with piles of documentation everywhere.  This documentation is entirely
# generated from lib/camping-unabridged.rb using RDoc and our "flipbook" template
# found in the extras directory of any camping distribution.
%w[uri stringio rack].map { |l| require l }

class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).send(:define_method,m,&b)
  end
end

# TODO: Rack (for production). Overriding r404, r500 and r501.
#
# Ready for developing with Camping?  Just follow along and we'll explain
# everything in a few minutes.  If there's a specific thing you're wondering
# about, here are some guidelines of how Camping and the documentation is organized:
#
# * All the modules are documentated with a little overview, followed by
#   all the methods defined there.
# * Camping::Controllers explains all you need to know about taking care
#   of the request and returning a response.
# * Camping::Models explains how you interact with the database, or other data sources.
# * Camping::Views explains how you can easily generate HTML from plain Ruby.
# * Camping::Helpers is a module with useful helpers, both for the controllers and the views.
# * Camping::Base is a module which is included in all your controllers.
#
#
# == Starting My First App
# 
# When you're going to start a new app in Camping, you simply open
# your favorite text editor and start writing:
#
#   require 'camping'
#   Camping.goes :Blog
#   
#   module Blog
#     # lots of code
#   end
# 
# What's important to know, is that <tt>Camping.goes :Blog</tt> copies the
# Camping-module into the Blog-module.  So whenever you see Camping in this
# documentation, you can replace it with Blog and everything should work
# as expected.
#
# By not modifying the Camping-module itself, you can have all your apps
# running in the same process and have less moving parts.  In fact, we recommend
# splitting larger apps into several, smaller ones to make it more manageable.
#
# == The Camping Server (for development)
#
# Camping includes a pretty nifty server which is built for development.
# It follows these rules:
# 
# * Load all Camping apps in a directory or a file.
# * Load new apps that appear in that directory or that file.
# * Mount those apps according to their name. (e.g. Blog is mounted at /blog.)
# * Run each app's <tt>create</tt> method upon startup.
# * Reload the app if its modification time changes.
# * Reload the app if it requires any files under the same directory and one of their modification times changes.
# * Support the X-Sendfile header.
#
# Run it like this:
#
#   camping examples/        # Mounts all apps in that directory
#   camping blog.rb          # Mounts Blog at /
#
# And visit http://localhost:3301/ in your browser.  Ready for some development?
#
#
# == MVC
#
# Camping follows the MVC-pattern, which means you'll separate your app into
# three parts: Models, views and controllers.  Let's start with the last:
#
# === Controllers
#
#   module Blog::Controllers
#     class Index
#       def get
#         @posts = Post.all
#         render :index
#       end
#     end
#   end   
# 
# The controllers are the heart of your app: They respond to a request from
# the user, process it and return an appropriate response.  Have a look at
# Camping::Controllers in order to fully understand how controllers work
# and how you should use them in Camping.
#
# === Models
#
#   module Blog::Models
#     class Post < Base; belongs_to :user; end
#     class Comment < Base; belongs_to :user; end
#     class User < Base; end
#   end
#
# Most apps needs to handle _data_ in some way: A blog needs a place to save
# and retrieve posts and comments; a wiki needs to store the pages somewhere.
# A _database_ is (most of the time) a great place to save such data.  Camping
# uses (just like Rails) ActiveRecord to abstract the boring details down to
# beautiful Ruby.  Read Camping::Models to learn how to use them in your app.
#
# === Views
#
#   module Blog::Views
#     def layout
#       html do
#         head { title "My Blog" }
#         body do
#           h1 "My Blog"
#           self << yield
#         end
#       end
#     end
#   
#     def index
#       @posts.each do |post|
#         h2 post.title
#         self << post.content
#       end
#     end
#   end
#
# Since we're on the web, we need to return the language which the web speaks:
# HTML. Writing HTML manually can be tedious and boring.  Camping uses Markaby
# which lets you write HTML in Ruby - simple and elegant.  As always, read
# Camping::Views to get a overview of how to use views.
#
# === Helpers
#
# I know, I know: Helpers don't fit into the MVC-pattern.  That doesn't mean
# they're useless, though.  Whenever you need a snippet in several controllers
# or views, you should refactor it out to a helper.  Camping includes a
# sensible collection of helpers in Camping::Helpers.
#
#
# == Tips & Tricks
# 
# === The <tt>create</tt> method
#
# It's a rule in Camping which says that the <tt>create</tt> method should be
# called when the server starts up.  The Camping Server does this, and so
# should you in your environment.
#
# This is a good place to check for database tables and create those tables
# to save users of your application from needing to manually set them up.
#
#   def Blog.create
#     Blog::Models::Base.establish_connection(
#       :adapter => 'sqlite3',
#       :database => 'blog.db'
#     )
#     Blog::Models.create_schama 
#   end 
#
# === Service Override
#
# Occassionally, you may want to intercept controller calls or do some cleanup
# afterwards.  Many other frameworks have before-, after- and around-filters
# to do that.  Camping has no facility for doing this. It's not worth the bytes.
#
# Instead, you can override <tt>service</tt>, which handles all controller calls.
# You can do include into specific controllers or right into the main application module.
#
#   module MySession
#     def service(*a)
#       # Do stuff before
#       @session = MyApp::Session.new
#       # Run regular controller
#       super(*a)
#     ensure
#       # Do stuff after
#       @session.close
#     end
#   end
#   
#   module MyApp
#     include MySession
#
#     module Controllers
#       class Index
#         include OtherOverload
#       end
#     end
#   end
module Camping
  C = self
  S = IO.read(__FILE__) rescue nil
  P = "<h1>Cam\ping Problem!</h1><h2>%s</h2>"
  U = Rack::Utils
  Apps = []
  # TODO: @input[:page] != @input['page']
  # An object-like Hash.
  # All Camping query string and cookie variables are loaded as this.
  # 
  # To access the query string, for instance, use the <tt>@input</tt> variable.
  #
  #   module Blog::Controllers
  #     class Index < R '/'
  #       def get
  #         if page = @input.page.to_i > 0
  #           page -= 1
  #         end
  #         @posts = Post.find :all, :offset => page * 20, :limit => 20
  #         render :index
  #       end
  #     end
  #   end
  #
  # In the above example if you visit <tt>/?page=2</tt>, you'll get the second
  # page of twenty posts.  You can also use <tt>@input[:page]</tt> or <tt>@input['page']</tt>
  # to get the value for the <tt>page</tt> query variable.
  #
  # Use the <tt>@cookies</tt> variable in the same fashion to access cookie variables.
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
  
  # TODO: Fair enough. Maybe complete the ActionPack example?
  # Helpers contains methods available in your controllers and views.  You may add
  # methods of your own to this module, including many helper methods from Rails.
  # This is analogous to Rails' <tt>ApplicationHelper</tt> module.
  #
  # == Using ActionPack Helpers
  #
  # If you'd like to include helpers from Rails' modules, you'll need to look up the
  # helper module in the Rails documentation at http://api.rubyonrails.org/.
  #
  # For example, if you look up the <tt>ActionView::Helpers::FormHelper</tt> class,
  # you'll find that it's loaded from the <tt>action_view/helpers/form_helper.rb</tt>
  # file.  You'll need to have the ActionPack gem installed for this to work.
  #
  #   require 'action_view/helpers/form_helper.rb'
  #
  #   # This example is unfinished.. soon..
  #
  module Helpers
    # From inside your controllers and views, you will often need to figure out
    # the route used to get to a certain controller +c+.  Pass the controller class
    # and any arguments into the R method, a string containing the route will be
    # returned to you.
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
    # You may also pass in a model object and the ID of the object will be used.
    #
    # If a controller has many routes, the route will be selected if it is the
    # first in the routing list to have the right number of arguments.
    #
    # == Using R in the View
    #
    # Keep in mind that this route doesn't include the root path.
    # You will need to use <tt>/</tt> (the slash method above) in your controllers.
    # Or, go ahead and use the Helpers#URL method to build a complete URL for a route.
    #
    # However, in your views, the :href, :src and :action attributes automatically
    # pass through the slash method, so you are encouraged to use <tt>R</tt> or
    # <tt>URL</tt> in your views.
    #
    #  module Blog::Views
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
    # <tt>http://localhost:3301/frodo</tt> and that a controller named <tt>Logout</tt>
    # is assigned to route <tt>/logout</tt>.  The HTML will come out as:
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
  # class Camping::R.  In some ways, this class is trying to do too much, but
  # it saves code for all the glue to stay in one place.
  #
  # Forgivable, considering that it's only really a handful of methods and accessors.
  #
  # == Treating controller methods like Response objects
  # TODO: I don't think this belongs here. Either Controllers or Camping.
  #
  # Camping originally came with a barebones Response object, but it's often much more readable
  # to just use your controller as the response.
  #
  # Go ahead and alter the status, cookies, headers and body instance variables as you
  # see fit in order to customize the response.
  #
  #   module Camping::Controllers
  #     class SoftLink
  #       def get
  #         redirect "/"
  #       end
  #     end
  #   end
  #
  # Is equivalent to:
  #
  #   module Camping::Controllers
  #     class SoftLink
  #       def get
  #         @status = 302
  #         @headers['Location'] = "/"
  #       end
  #     end
  #   end
  #
  module Base
    attr_accessor :input, :cookies, :headers, :body, :status, :root
    M = proc { |_, o, n| o.merge(n, &M) }

    # Display a view, calling it by its method name +v+.  If a <tt>layout</tt>
    # method is found in Camping::Views, it will be used to wrap the HTML.
    #
    #   module Camping::Controllers
    #     class Show
    #       def get
    #         @posts = Post.find :all
    #         render :index
    #       end
    #     end
    #   end
    #
    # You can also return directly HTML by just passing a block
    #
    def render(v,*a,&b)
      mab(/^_/!~v.to_s){send(v,*a,&b)}
    end

    # You can directly return HTML form your controller for quick debugging
    # by calling this method and pass some Markaby to it.
    # 
    #   module Camping::Controllers
    #     class Info
    #       def get; mab{ code @headers.inspect } end
    #     end
    #   end
    #
    # You can also pass true to use the :layout HTML wrapping method
    #
    def mab(l=nil,&b)
      m=Mab.new({},self)
      s=m.capture(&b)
      s=m.capture{layout{s}} if l && m.respond_to?(:layout)
      s
    end

    # A quick means of setting this controller's status, body and headers.
    # Used internally by Camping, but... by all means...
    #
    #   r(302, '', 'Location' => self / "/view/12")
    #
    # Is equivalent to:
    #
    #   redirect "/view/12"
    #
    # You can also switch the body and the header in order to support Rack:
    #
    #  r(302, {'Location' => self / "/view/12"}, '')
    #  r(*another_app.call(@env))
    #
    # See also: #r404, #r500 and #r501
    def r(s, b, h = {})
      b, h = h, b if Hash === b
      @status = s
      @headers.merge!(h)
      @body = b
    end

    # Formulate a redirect response: a 302 status with <tt>Location</tt> header
    # and a blank body.  Uses Helpers#URL to build the location from a controller
    # route or path.
    #
    # So, given a root of <tt>http://localhost:3301/articles</tt>:
    #
    #   redirect "view/12"    # redirects to "//localhost:3301/articles/view/12"
    #   redirect View, 12     # redirects to "//localhost:3301/articles/view/12"
    #
    # <b>NOTE:</b> This method doesn't magically exit your methods and redirect.
    # You'll need to <tt>return redirect(...)</tt> if this isn't the last statement
    # in your code.
    #
    # See: Controllers
    def redirect(*a)
      r(302,'','Location'=>URL(*a).to_s)
    end

    # Called when a controller was not found. It is mainly used internally, but it can
    # also be useful for you, if you want to filter some parameters.
    #
    # See: Controllers
    def r404(p)
      P % "#{p} not found"
    end

    # If there is a parse error in Camping or in your application's source code,
    # it will not be caught by Camping.  The controller class +k+ and request method +m+ (GET, POST, etc.) where the error
    # took place are passed in, along with the Exception +e+ which can be mined for useful info.
    #
    # You can overide it, but if you have an error in here, it will be uncaught !
    #
    # See: Controllers
    def r500(k,m,e)
      raise e
    end

    # Called if an undefined method is called on a controller, along with the request method +m+ (GET, POST, etc.)
    #
    # See: Controllers
    def r501(m)
      P % "#{m.upcase} not implemented"
    end

    # Turn a controller into an array.  This is designed to be used to pipe
    # controllers into the <tt>r</tt> method.  A great way to forward your
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
        v = {:value => v, :path => self / "/"} if String===v
        r.set_cookie(k, v)
      end
      r.to_a
    end
    
    def initialize(env, m) #:nodoc: 
      r = @request = Rack::Request.new(@env = env)
      @root, p, @cookies, @state,
      @headers, @status, @method =
      (env['SCRIPT_NAME']||'').sub(/\/$/,''), 
      H[r.params], H[r.cookies], H[r.session],
      {}, m =~ /r(\d+)/ ? $1.to_i : 200, m
      
      @input = p.inject(H[]) do |h, (k, v)|
        h.merge(k.split(/[\]\[]+/).reverse.inject(v) { |x, i| H[i => x] }, &M)
      end
    end

    # All requests pass through this method before going to the controller.
    # Some magic in Camping can be performed by overriding this method.
    #
    # See: Camping
    def service(*a)
      r = catch(:halt){send(@method, *a)}
      @body ||= r 
      self
    end
  end
  
  # In order to fully understand controllers and how they are used, you
  # should know a bit about HTTP - the protocol behind The World Wide Web.
  #
  # == Request
  #
  # HTTP is built around _requests_.  When a user types "http://yoursite.com/"
  # in his web browser, the browser starts making requests to the server.
  # It's basically asking the server to do what the user want.  When the server
  # has decided what to do, it sends a _response_ back to the browser which
  # is then showed to the user.
  #
  # We can brutually split a request into three parts: a resource, a method
  # and the rest.
  #
  # === Resource
  #
  # A _resource_ in HTTP is simply a name of a _thing_ - it's a noun. Just like
  # "home", "blog post" and "comment" are nouns in our world, are +/+,
  # +/post/123+ and +/post/123/comment/456+ resources in HTTP.
  #
  # Nouns are well and good, but just like you can't build a sentence with
  # only nouns, you can't build a request with only a resource.  We need verbs!
  #
  # === Method
  #
  # _Methods_ are the verbs in HTTP.  It's not enough to have the name of
  # what you want, you have to tell _what_ you want to do too.  Since
  # we're speaking with machines, we have to stick to these:
  #
  # * GET
  # * POST
  # * (PUT)
  # * (DELTE)
  #
  # GET is the default method.  When you type an address or click a link in
  # your browser, it's smart enough to realize that you want to get that
  # resource.  GET also is the simplest of the methods: it should not _do_
  # anything, just return the content.
  #
  # The three others are focused on actions. POST for create, PUT for
  # update and DELETE for, uhm, delete.  You may have noticed the parenthesis
  # around PUT and DELETE, and the reason for that is quite sad:
  #
  # When the web was still young, some realized that they didn't _need_
  # PUT and DELETE; they could just use POST and put the verb in the
  # resource: POST /posts/delete/1.  This doesn't make sense at all, but
  # it happened and <strong>right now browsers only support GET and POST.</strong>
  #
  # === The Rest
  #
  # HTTP is also very flexible, so the browser can send all kind of other
  # metadata (called _headers_).  This includes the name of the browser, the  
  # preferred language, the domain of the server and much, much more.
  # 
  # In POST, PUT and DELETE you can also send some arbitrary data (called
  # the _body_).  This is used for instance when you upload a file.
  #
  # Probably the most important part is that the browser can send parameters.
  # In all the methods you can tack them on to the end after a question mark
  # (<tt>/search?query=camping</tt>), while POST, PUT and DELETE also allows
  # to send them, hidden from the user, in the body.
  #
  # == Response
  #
  # When the browser has sent the request to the server, the server has
  # to return a response.  We can also split the response into three parts:
  # a status code, headers and a body.
  #
  # === Status Code
  #
  # The status code tells a bit about the response.  For instance:
  #
  # * 200 means everything went fine and no problems occured.
  # * 401 means you have to login.
  # * 404 means the resource couldn't be found.
  # * 500 means the server encountered an error.
  #
  # This is just a small selection.  Wikipedia has a {nice list with _all_ the
  # codes}[http://en.wikipedia.org/wiki/List_of_HTTP_status_codes].
  #
  # === Headers
  #
  # Just like the headers in the request, the headers in the response are
  # used to send useful metadata back to the browser.  Examples of this
  # are what kind of content this is, the length of the body and if the
  # browser should give a "File Download" dialogue box.
  #
  # === Body
  #
  # The body is simply what the user is going to see.
  #
  # == Using controllers in Camping
  #
  # I guess you're bored with all of this (seemingly useless) theory, but we
  # believe it's better to understand HTTP now than later.  Let's however
  # start with some coding.
  #
  # In Camping, a controller is simply a resource:
  #
  #   module Blog::Controllers
  #     class Posts < R '/posts'
  #       def get
  #         "Hello from GET"
  #       end
  # 
  #       def post
  #         "Hello from POST"
  #       end
  #     end
  #   end
  #
  # Camping will take care if of all the boring stuff, and whenever someone
  # tries to GET or POST <tt>/posts</tt> it will display this nice message.
  #
  # If someone tries to DELETE <tt>/posts</tt>, Camping will return a 501
  # response (which means the method wasn't implemented).  If someone tries to
  # access <tt>/postsss</tt>, it will return a 404 response (no such resource).
  #
  # === Specialized resources
  #
  # Most of the time your resources needs to match more than a single, static
  # path (like <tt>/posts</tt> above).  Luckily, you can use regular expressions
  # in your routes.  Wrap the rules with some parethesis and it will also be
  # sent as arguments to your method:
  #
  #   module Blog::Controllers
  #     class Post < R '/post/(\d+)'
  #       def get(id)
  #         case id.to_i
  #         when 1
  #           "You're looking at the first post (/post/1)!"
  #         when 2
  #           "You're looking at the second post (/post/2)!"
  #         else
  #           "Meh."
  #         end
  #       end
  #     end
  #   
  #     class Page < R '/user/(\w+)/page/(\w+)', '/u/(\w+)/(\w+)'
  #       def get(user, page_name)
  #         "You're visiting #{user}'s #{page_name}"
  #       end
  #     end
  #   end
  #
  # As you can see, you can also give your controllers several routes to match.
  #
  # === Magic resources
  # 
  # Very often, you will name your controllers identical to it's route.  If
  # you leave out the route and just define the controller as a class
  # (<tt>class Posts</tt>), Camping will automatically build the route using some magic:
  #
  # First it will split the controller name up by words.  For instance
  # +VeryNiftyRoute+ will be split up into +Very+, +Nifty+ and +Route+.
  #
  # Then it substitutes each part using these rules:
  # 
  # * Index turns into /
  # * X turns into ([^/]+)
  # * N turns into (\\\d+)
  # * Everything else turns into lowercase
  #
  # Finally it puts a slash between the parts.
  #
  # It can take some time to grasp, but it's actually very nice since you
  # avoid repeating the route in the name (or vica versa).  Have a look at the
  # examples below if you're still a little confused. 
  #
  #   module Blog::Controllers
  #     # Matches: /
  #     class Index
  #     end
  #     
  #     # Matches: /post/(\d+)
  #     class PostN
  #     end
  #     
  #     # Matches: /very/nifty/route
  #     class VeryNiftyRoute
  #     end
  #   end
  #
  # TODO: @input & @cookies at least.
  # Controllers is a module for placing classes which handle URLs.  This is done
  # by defining a route to each class using the Controllers::R method.
  #
  #   module Camping::Controllers
  #     class Edit < R '/edit/(\d+)'
  #       def get; end
  #       def post; end
  #     end
  #   end
  #
  # If no route is set, Camping will guess the route from the class name.
  # The rule is very simple: the route becomes a slash followed by the lowercased
  # class name.  See Controllers::D for the complete rules of dispatch.
  module Controllers
    @r = []
    class << self
      # An array containing the various controllers available for dispatch.
      def r #:nodoc:
        @r
      end
      # Add routes to a controller class by piling them into the R method.
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
      # You will need to use routes in either of these cases:
      #
      # * You want to assign multiple routes to a controller.
      # * You want your controller to receive arguments.
      #
      # Most of the time the rules inferred by dispatch method Controllers::D will get you
      # by just fine.
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
      # # Classes without routes, since they refer to a very specific URL.
      # # Classes with routes are searched in order of their creation.
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
      # The route maker, this is called by Camping internally, you shouldn't need to call it.
      #
      # Still, it's worth know what this method does.  Since Ruby doesn't keep track of class
      # creation order, we're keeping an internal list of the controllers which inherit from R().
      # This method goes through and adds all the remaining routes to the beginning of the list
      # and ensures all the controllers have the right mixins.
      #
      # Anyway, if you are calling the URI dispatcher from outside of a Camping server, you'll
      # definitely need to call this at least once to set things up.
      def M
        def M #:nodoc:
        end
        constants.map { |c|
          k=const_get(c)
          k.send :include,C,Base,Helpers,Models
          @r=[k]+r if r-[k]==r
          k.meta_def(:urls){["/#{c.scan(/.[^A-Z]*/).map(&N.method(:[]))*'/'}"]}if !k.respond_to?:urls
        }
      end
    end

    # Internal controller with no route. Used by #D and C.call to show internal messages.
    I = R()
  end
  X = Controllers

  class << self
    # When you are running many applications, you may want to create independent
    # modules for each Camping application.  Namespaces for each.  Camping::goes
    # defines a toplevel constant with the whole MVC rack inside.
    #
    #   require 'camping'
    #   Camping.goes :Blog
    #
    #   module Blog::Controllers; ... end
    #   module Blog::Models;      ... end
    #   module Blog::Views;       ... end
    #
    def goes(m)
      Apps << eval(S.gsub(/Camping/,m.to_s), TOPLEVEL_BINDING)
    end
    
    # Ruby web servers use this method to enter the Camping realm. The e
    # argument is the environment variables hash as per the Rack specification.
    # And array with [statuc, headers, body] is expected at the output.
    def call(e)
      X.M
      p = e['PATH_INFO'] = U.unescape(e['PATH_INFO'])
      k,m,*a=X.D p,(e['REQUEST_METHOD']||'get').downcase
      k.new(e,m).service(*a).to_a
    rescue
      r500(:I, k, m, $!, :env => e).to_a
    end

    # The Camping scriptable dispatcher.  Any unhandled method call to the app module will
    # be sent to a controller class, specified as an argument.
    #
    #   Blog.get(:Index)
    #   #=> #<Blog::Controllers::Index ... >
    #
    # The controller object contains all the @cookies, @body, @headers, etc. formulated by
    # the response.
    #
    # You can also feed environment variables and query variables as a hash, the final
    # argument.
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
      e = H[Rack::MockRequest.env_for('',h[:env]||{})]
      k = X.const_get(c).new(e,m.to_s)
      k.send("input=", h[:input]) if h[:input]
      k.service(*a)
    end
    
    # Injects a middleware:
    #
    #   module Blog
    #     use Rack::MethodOverride
    #     use Rack::Session::Memcache, :key => "session"
    #   end
    def use(*a)
      m = a.shift.new(method(:call), *a)
      meta_def(:call) { |e| m.call(e) }
    end
  end
  
  # Views is an empty module for storing methods which create HTML.  The HTML
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
  # invoke the template.  The views and controllers will share instance
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
  
  # TODO: Migrations
  # Models is an empty Ruby module for housing model classes derived
  # from ActiveRecord::Base.  As a shortcut, you may derive from Base
  # which is an alias for ActiveRecord::Base.
  #
  #   module Camping::Models
  #     class Post < Base; belongs_to :user end
  #     class User < Base; has_many :posts end
  #   end
  #
  # == Where Models are Used
  #
  # Models are used in your controller classes.  However, if your model class
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
      def Y;self;end
  end
 
  autoload :Mab, 'camping/mab'
  C
end

