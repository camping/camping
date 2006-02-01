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
#
# == Requirements
#
# Camping requires at least Ruby 1.8.2.
#
# Camping depends on the following libraries.  If you install through RubyGems,
# these will be automatically installed for you.
#
# * ActiveRecord, used in your models.
#   ActiveRecord is an object-to-relational database mapper with adapters
#   for SQLite3, MySQL, PostgreSQL, SQL Server and more.
# * Markaby, used in your views to describe HTML in plain Ruby.
# * MetAid, a few metaprogramming methods which Camping uses.
# * Tempfile, for storing file uploads.
#
# Camping also works well with Mongrel, the swift Ruby web server.
# http://rubyforge.org/projects/mongrel  Mongrel comes with examples
# in its <tt>examples/camping</tt> directory. 
#
%w[rubygems active_record markaby metaid tempfile].each { |lib| require lib }

# == Camping 
#
# The camping module contains three modules for separating your application:
#
# * Camping::Models for your database interaction classes, all derived from ActiveRecord::Base.
# * Camping::Controllers for storing controller classes, which map URLs to code.
# * Camping::Views for storing methods which generate HTML.
#
# Of use to you is also one module for storing helpful additional methods:
#
# * Camping::Helpers which can be used in controllers and views.
#
# == The postamble
#
# Most Camping applications contain the entire application in a single script.
# The script begins by requiring Camping, then fills each of the three modules
# described above with classes and methods.  Finally, a postamble puts the wheels
# in motion.
#
#   if __FILE__ == $0
#     Camping::Models::Base.establish_connection :adapter => 'sqlite3',
#         :database => 'blog3.db'
#     Camping::Models::Base.logger = Logger.new('camping.log')
#     Camping.create if Camping.respond_to? :create
#     puts Camping.run
#   end
#
# In the postamble, your job is to setup Camping::Models::Base (see: ActiveRecord::Base) 
# and call Camping::run in a request loop.  The above postamble is for a standard
# CGI setup, where the web server manages the request loop and calls the script once
# for every request.
#
# For other configurations, see 
# http://code.whytheluckystiff.net/camping/wiki/PostAmbles
#
# == The <tt>create</tt> method
#
# Many postambles will check for your application's <tt>create</tt> method and will run it
# when the web server starts up.  This is a good place to check for database tables and create
# those tables to save users of your application from needing to manually set them up.
#
#   def Blog.create
#     unless Blog::Models::Post.table_exists?
#       ActiveRecord::Schema.define do
#         create_table :blog_posts, :force => true do |t|
#           t.column :id,       :integer, :null => false
#           t.column :user_id,  :integer, :null => false
#           t.column :title,    :string,  :limit => 255
#           t.column :body,     :text
#         end
#       end
#     end
#   end 
#
# For more tips, see http://code.whytheluckystiff.net/camping/wiki/GiveUsTheCreateMethod.
module Camping
  C = self
  F = __FILE__
  S = IO.read(F).gsub(/_+FILE_+/,F.dump)

  # An object-like Hash, based on ActiveSupport's HashWithIndifferentAccess.
  # All Camping query string and cookie variables are loaded as this.
  # 
  # To access the query string, for instance, use the <tt>@input</tt> variable.
  #
  #   module Blog::Models
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
  class H < HashWithIndifferentAccess
    def method_missing(m,*a)
        if m.to_s =~ /=$/
            self[$`] = a[0]
        elsif a.empty?
            self[m]
        else
            raise NoMethodError, "#{m}"
        end
    end
  end

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
    # Keep in mind that this route doesn't include the root path.  Occassionally
    # you will need to use <tt>/</tt> (the slash method above).
    def R(c,*args)
      p = /\(.+?\)/
      args.inject(c.urls.find{|x|x.scan(p).size==args.size}.dup){|str,a|
        str.sub(p,(a.__send__(a.class.primary_key) rescue a).to_s)
      }
    end
    # Shows AR validation errors for the object passed. 
    # There is no output if there are no errors.
    #
    # An example might look like:
    #
    #   errors_for @post
    #
    # Might (depending on actual data) render something like this in Markaby:
    #
    #   ul.errors do
    #     li "Body can't be empty"
    #     li "Title must be unique"
    #   end
    #
    # Add a simple ul.errors {color:red; font-weight:bold;} CSS rule and you
    # have built-in, usable error checking in only one line of code. :-)
    #
    # See AR validation documentation for details on validations.
    def errors_for(o); ul.errors { o.errors.each_full { |er| li er } } unless o.errors.empty?; end
    # Simply builds the complete URL from a relative or absolute path +p+.  If your
    # application is running from <tt>/blog</tt>:
    #
    #   self / "/view/1"    #=> "/blog/view/1"
    #   self / "styles.css" #=> "styles.css"
    #   self / R(Edit, 1)   #=> "/blog/edit/1"
    #
    def /(p); p[/^\//]?@root+p:p end
  end

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
  #
  # == Special classes
  #
  # There are two special classes used for handling 404 and 500 errors.  The
  # NotFound class handles URLs not found.  The ServerError class handles exceptions
  # uncaught by your application.
  module Controllers
    # Controllers::Base is built into each controller by way of the generic routing
    # class Controllers::R.  In some ways, this class is trying to do too much, but
    # it saves code for all the glue to stay in one place.
    #
    # Forgivable, considering that it's only really a handful of methods and accessors.
    #
    # == Treating controller methods like Response objects
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
      include Helpers
      attr_accessor :input, :cookies, :env, :headers, :body, :status, :root
      # Display a view, calling it by its method name +m+.  If a <tt>layout</tt>
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
      def render(m); end; undef_method :render

      # Any stray method calls will be passed to Markaby.  This means you can reply
      # with HTML directly from your controller for quick debugging.
      #
      #   module Camping::Controllers
      #     class Info
      #       def get; code @env.inspect end
      #     end
      #   end
      #
      # If you have a <tt>layout</tt> method in Camping::Views, it will be used to
      # wrap the HTML.
      def method_missing(m, *a, &b)
        str = m==:render ? markaview(*a, &b):eval("markaby.#{m}(*a, &b)")
        str = markaview(:layout) { str } if Views.method_defined? :layout
        r(200, str.to_s)
      end

      # Formulate a redirect response: a 302 status with <tt>Location</tt> header
      # and a blank body.  If +c+ is a string, the root path will be added.  If
      # +c+ is a controller class, Helpers::R will be used to route the redirect
      # and the root path will be added.
      #
      # So, given a root of <tt>/articles</tt>:
      #
      #   redirect "view/12"    # redirects to "/articles/view/12"
      #   redirect View, 12     # redirects to "/articles/view/12"
      #
      def redirect(c, *args)
        c = R(c,*args) if c.respond_to? :urls
        r(302, '', 'Location' => self/c)
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
      def r(s, b, h = {}); @status = s; @headers.merge!(h); @body = b; end

      def service(r, e, m, a) #:nodoc:
        @status, @env, @headers, @root = 200, e, {'Content-Type'=>'text/html'}, e['SCRIPT_NAME']
        cook = C.kp(e['HTTP_COOKIE'])
        qs = C.qs_parse(e['QUERY_STRING'])
        if "post" == m
          inp = r.read(e['CONTENT_LENGTH'].to_i)
          if %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)|n.match(e['CONTENT_TYPE'])
            b = "--#$1"
            inp.split(/(?:\r?\n|\A)#{ Regexp::quote( b ) }(?:--)?\r\n/m).each { |pt|
              h,v=pt.split("\r\n\r\n",2);fh={}
              [:name, :filename].each { |x|
                fh[x] = $1 if h =~ /^Content-Disposition: form-data;.*(?:\s#{x}="([^"]+)")/m
              }
              fn = fh[:name]
              if fh[:filename]
                fh[:type]=$1 if h =~ /^Content-Type: (.+?)(\r\n|\Z)/m
                fh[:tempfile]=Tempfile.new("C").instance_eval {binmode;write v;rewind;self}
              else
                fh=v
              end
              qs[fn]=fh if fn
            }
          else
            qs.merge!(C.qs_parse(inp))
          end
        end
        @cookies, @input = cook.dup, qs.dup

        @body = send(m, *a) if respond_to? m
        @headers['Set-Cookie'] = @cookies.map { |k,v| "#{k}=#{C.escape(v)}; path=#{self/"/"}" if v != cook[k] }.compact
        self
      end
      def to_s #:nodoc:
        "Status: #{@status}\n#{@headers.map{|k,v|[*v].map{|x|"#{k}: #{x}"}*"\n"}*"\n"}\n\n#{@body}"
      end
      def markaby #:nodoc:
          Mab.new( instance_variables.map { |iv| 
            [iv[1..-1], instance_variable_get(iv)] } )
      end
      def markaview(m, *a, &b) #:nodoc:
        h=markaby
        h.send(m, *a, &b)
        h.to_s
      end
    end

    # The R class is the parent class for all controllers and ensures they all get the Base mixin.
    class R; include Base end

    # The NotFound class is a special controller class for handling 404 errors, in case you'd
    # like to alter the appearance of the 404.  The path is passed in as +p+.
    #
    #   module Camping::Controllers
    #     class NotFound
    #       def get(p)
    #         @status = 404
    #         div do
    #           h1 'Camping Problem!'
    #           h2 "#{p} not found"
    #         end
    #       end
    #     end
    #   end
    #
    class NotFound; def get(p); r(404, div{h1("Cam\ping Problem!")+h2("#{p} not found")}); end end

    # The ServerError class is a special controller class for handling many (but not all) 500 errors.
    # If there is a parse error in Camping or in your application's source code, it will not be caught
    # by Camping.  The controller class +k+ and request method +m+ (GET, POST, etc.) where the error
    # took place are passed in, along with the Exception +e+ which can be mined for useful info.
    #
    #   module Camping::Controllers
    #     class ServerError
    #       def get(k,m,e)
    #         @status = 500
    #         div do
    #           h1 'Camping Problem!'
    #           h2 "in #{k}.#{m}"
    #           h3 "#{e.class} #{e.message}:"
    #           ul do
    #             e.backtrace.each do |bt|
    #               li bt
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    class ServerError; include Base; def get(k,m,e); r(500, Mab.new { h1 "Cam\ping Problem!"; h2 "#{k}.#{m}"; h3 "#{e.class} #{e.message}:"; ul { e.backtrace.each { |bt| li bt } } }.to_s) end end

    class << self
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
      def R(*urls); Class.new(R) { meta_def(:urls) { urls } }; end

      # Dispatch routes to controller classes.  Classes are searched in no particular order.
      # For each class, routes are checked for a match based on their order in the routing list
      # given to Controllers::R.  If no routes were given, the dispatcher uses a slash followed
      # by the name of the controller lowercased.
      def D(path)
        constants.inject(nil) do |d,c| 
            k = const_get(c)
            k.meta_def(:urls){["/#{c.downcase}"]}if !(k<R)
            d||([k, $~[1..-1]] if k.urls.find { |x| path =~ /^#{x}\/?$/ })
        end||[NotFound, [path]]
      end
    end
  end

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
        eval(S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING)
    end

    # URL escapes a string.
    #
    #   Camping.escape("I'd go to the museum straightway!")  
    #     #=> "I%27d+go+to+the+museum+straightway%21"
    #

    def escape(s); s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n){'%'+$1.unpack('H2'*$1.size).join('%').upcase}.tr(' ', '+') end
    # Unescapes a URL-encoded string.
    #
    #   Camping.unescape("I%27d+go+to+the+museum+straightway%21") 
    #     #=> "I'd go to the museum straightway!"
    #
    def unescape(s); s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){[$1.delete('%')].pack('H*')} end

    # Parses a query string into an Camping::H object.
    #
    #   input = Camping.qs_parse("name=Philarp+Tremain&hair=sandy+blonde")
    #   input.name
    #     #=> "Philarp Tremaine"
    #
    # Also parses out the Hash-like syntax used in PHP and Rails and builds
    # nested hashes from it.
    #
    #   input = Camping.qs_parse("post[id]=1&post[user]=_why")
    #     #=> {'post' => {'id' => '1', 'user' => '_why'}}
    #
    def qs_parse(qs, d = '&;')
        m = proc {|_,o,n|o.merge(n,&m)rescue([*o]<<n)}
        (qs||'').
            split(/[#{d}] */n).
            inject(H[]) { |h,p| k, v=unescape(p).split('=',2)
                h.merge(k.split(/[\]\[]+/).reverse.
                    inject(v) { |x,i| H[i,x] },&m)
            } 
    end

    # Parses a string of cookies from the <tt>Cookie</tt> header.
    def kp(s); c = qs_parse(s, ';,'); end

    # Fields a request through Camping.  For traditional CGI applications, the method can be
    # executed without arguments.
    #
    #   if __FILE__ == $0
    #     Camping::Models::Base.establish_connection :adapter => 'sqlite3',
    #         :database => 'blog3.db'
    #     Camping::Models::Base.logger = Logger.new('camping.log')
    #     puts Camping.run
    #   end
    #
    # The Camping controller returned from <tt>run</tt> has a <tt>to_s</tt> method in case you
    # are running from CGI or want to output the full HTTP output.  In the above example, <tt>puts</tt>
    # will call <tt>to_s</tt> for you.
    #
    # For FastCGI and Webrick-loaded applications, you will need to use a request loop, with <tt>run</tt>
    # at the center, passing in the read +r+ and write +w+ streams.  You will also need to mimick or
    # pass in the <tt>ENV</tt> replacement as part of your wrapper.
    #
    #   if __FILE__ == $0
    #     require 'fcgi'
    #       Camping::Models::Base.establish_connection :adapter => 'sqlite3',
    #           :database => 'blog3.db'
    #       Camping::Models::Base.logger = Logger.new('camping.log')
    #       FCGI.each do |req|
    #         req.out << Camping.run req.in, req.env
    #         req.finish
    #       end
    #     end
    #   end
    #
    def run(r=$stdin)
      begin
        k, a = Controllers.D "/#{e['PATH_INFO']}".gsub(%r!/+!,'/')
        m = e['REQUEST_METHOD']||"GET"
        k.send :include, C, Controllers::Base, Models
        o = k.new
        o.service(r, e, m.downcase, a)
      rescue => x
        Controllers::ServerError.new.service(r, e, "get", [k,m,x])
      end
    end
  end

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
      A = ActiveRecord
      # Base is an alias for ActiveRecord::Base.  The big warning I'm going to give you
      # about this: *Base overloads table_name_prefix.*  This means that if you have a
      # model class Blog::Models::Post, it's table name will be <tt>blog_posts</tt>.
      Base = A::Base

      # The default prefix for Camping model classes is the topmost module name lowercase
      # and followed with an underscore.
      #
      #   Tepee::Models::Page.table_name_prefix
      #     #=> "tepee_pages"
      #
      def Base.table_name_prefix
          "#{name[/^(\w+)/,1]}_".downcase.sub(/^(#{A}|camping)_/i,'')
      end
  end

  # Views is an empty module for storing methods which create HTML.  The HTML is described
  # using the Markaby language.
  #
  # == Using the layout method
  #
  # If your Views module has a <tt>layout</tt> method defined, it will be called with a block
  # which will insert content from your view.
  module Views; include Controllers, Helpers end
  
  # The Mab class wraps Markaby, allowing it to run methods from Camping::Views
  # and also to replace :href and :action attributes in tags by prefixing the root
  # path.
  class Mab < Markaby::Builder
      include Views
      def tag!(*g,&b)
          h=g[-1]
          [:href,:action].each{|a|(h[a]=self/h[a])rescue 0}
          super 
      end
  end
end
