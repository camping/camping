#Getting Started

Start a new text file called nuts.rb. Here's what you put inside:
 
    Camping.goes :Nuts

Save it. Then, open a command prompt in the same directory. You'll want to
run:

    $ camping nuts.rb

And you should get a message which reads:

    ** Camping running on 0.0.0.0:3301.

This means that right now The Camping Server is running on port 3301 on your
machine. Open your browser and visit http://localhost:3301/.

Your browser window should show:

    Camping Problem!
  
    / Not found

No problem with that. The Camping Server is running, but it doesn't know what
to show. Let's tell him.

##Hello clock

So, you've got Camping installed and it's running. Keep it running. You can
edit files and The Camping Server will reload automatically. When you need to
stop the server, press Control-C.

Let's show something. At the bottom of nuts.rb add:

    module Nuts::Controllers
      class Index < R '/'
        def get
          Time.now.to_s
        end
      end
    end

Save the file and refresh the browser window. Your browser window should show
the time, e.g.

    Sun Jul 15 12:56:15 +0200 2007

##Enjoying the view

The Camping microframework allows us to separate our code using the MVC
(Model-View-Controller) design pattern. Let's add a view to our Nuts
application. Replace the <tt>module Nuts::Controllers</tt> with:

    module Nuts::Controllers
      class Index < R '/'
        def get
          @time = Time.now
          render :sundial
        end
      end
    end

    module Nuts::Views
      def layout
        html do
          head do
            title { "Nuts And GORP" }
          end
          body { self << yield }
        end
      end

      def sundial
        p "The current time is: #{@time}"
      end
    end
  
Save the file and refresh your browser window and it should show a message
like:

    The current time is: Sun Jul 15 13:05:41 +0200 2007

And the window title reads "Nuts And GORP".

Here you can see we call <tt>render :sundial</tt> from our controller. This
does exactly what it says, and renders our <tt>sundial</tt> method. We've also
added a special method called <tt>layout</tt> which Camping will automatically
wrap our sundial output in. If you're familiar with HTML, you'll see that our
view contains what looks HTML tag names. This is Markaby, which is like
writing HTML using Ruby!

Soon enough, you'll find that you can return anything from the controller, and
it will be sent to the browser. But let's keep that for later and start
investigating the routes.

##Routes

You probably noticed the weird <tt>R '/'</tt> syntax in the previous page.
This is an uncommon feature of Ruby that is used in our favorite
microframework, to describe the routes which the controller can be accessed
on.

These routes can be very powerful, but we're going to have look at the
simplest ones first.

    module Nuts::Controllers
      class Words < R '/welcome/to/my/site'
        def get
          "You got here by: /welcome/to/my/site"
        end
      end
    
      class Digits < R '/nuts/(\d+)'
        def get(number)
          "You got here by: /nuts/#{number}"
        end
      end

      class Segment < R '/gorp/([^/]+)'
        def get(everything_else_than_a_slash)
          "You got here by: /gorp/#{everything_else_than_a_slash}"
        end
      end
    
      class DigitsAndEverything < R '/nuts/(\d+)/([^/]+)'
        def get(number, everything)
          "You got here by: /nuts/#{number}/#{everything}"
        end
      end
    end
  
Add this to `nuts.rb` and try if you can hit all of the controllers. 

Also notice how everything inside a parenthesis gets passed into the method,
and is ready at your disposal.

###Simpler routes

This just in:

    module Nuts::Controllers
      class Index
        def get
          "You got here by: /"
        end
      end
    
      class WelcomeToMySite
        def get
          "You got here by: /welcome/to/my/site"
        end
      end
      
      class NutsN
        def get(number)
          "You got here by: /nuts/#{number}"
        end
      end
    
      class GorpX
        def get(everything_else_than_a_slash)
          "You got here by: /gorp/#{everything_else_than_a_slash}"
        end
      end
    
      class NutsNX
        def get(number, everything)
          "You got here by: /nuts/#{number}/#{everything}"
        end
      end
    end
  
Drop the <tt>< R</tt>-part and it attemps to read your mind. It won't always
succeed, but it can simplify your application once in a while.

## Modeling the world

You can get pretty far with what you've learned now, and hopefully you've been
playing a bit off-book, but it's time to take the next step: Storing data.

Let's start over again.

    Camping.goes :Nuts

    module Nuts::Models
      class Page < Base
      end
    end
  
Obviously, this won't do anything, since we don't have any controllers, but
let's rather have a look at we _do_ have.

We have a model named Page. This means we now can store wiki pages and
retrieve them later. In fact, we can have as many models as we want. Need one
for your users and one for your blog posts? Well, I think you already know how
to do it.

However, our model is missing something essential: a skeleton.
  
    Camping.goes :Nuts
  
    module Nuts::Models
      class Page < Base
      end
  
      class BasicFields < V 1.0
        def self.up
          create_table Page.table_name do |t|
            t.string :title
            t.text   :content
            # This gives us created_at and updated_at
            t.timestamps
          end
        end
  
        def self.down
          drop_table Page.table_name
        end
      end
    end
  
Now we have our first version of our model. It says:

  If you want to migrate up to version one,
    create the skeleton for the Page model,
    which should be able to store,
      "title" which is a string,
      "content" which is a larger text,
      "created_at" which is the time it was created,
      "updated_at" which is the previous time it was updated.
    
  If you want to migrate down from version one,
    remove the skeleton for the Page model.
    
This is called a _migration_. Whenever you want to change or add new models you simply add a new migration below, where you increase the version number. All of these migrations builds upon each other like LEGO blocks.

Now we just need to tell Camping to use our migration. Write this at the bottom of nuts.rb

    def Nuts.create
      Nuts::Models.create_schema
    end

When The Camping Server boots up, it will automatically call
<tt>Nuts.create</tt>. You can put all kind of startup-code here, but right now
we only want to create our skeleton (or upgrade if needed). Start The Camping
Server again and observe:
  
    $ camping nuts.rb
    ** Starting Mongrel on 0.0.0.0:3301
    -- create_table("nuts_schema_infos")
       -> 0.1035s
    ==  Nuts::Models::BasicFields: migrating ===================================
    -- create_table(:nuts_pages)
       -> 0.0033s
    ==  Nuts::Models::BasicFields: migrated (0.0038s) ==========================
  
Restart it, and enjoy the silence. There's no point of re-creating the
skeleton this time.

Before we go on, there's one rule you must known: Always place your models
before your migrations.

## Using our model

Let's explore how our model works by going into the _console_

    $ camping -C nuts.rb
    ** Starting console
    >>
  
Now it's waiting for your input, and will give you the answer when you press
Enter. Here's what I did, leaving out the boring answers. You should add your
own pages.

    >> Page = Nuts::Models::Page
    
    >> hiking = Page.new(:title => "Hiking")
    >> hiking.content = "You can also set the values like this."
    >> hiking.save

    >> page = Page.find_by_title("Hiking")
    => #<Nuts::Models::Page id: 1, ... >
    >> page = Page.find(1)
    => #<Nuts::Models::Page id: 1, ... >
    >> page.title
    >> page.content
    >> page.created_at
    >> page.updated_at
    
    >> Page.find_by_title("Fishing")
    => nil
    
    ## Page.create automatically saves the page for you.
    >> Page.create(:title => "Fishing", :content => "Go fish!")
    
    >> Page.count
    => 2
  
Now I have two pages: One about hiking and one about fishing.

##Wrapping it up

Wouldn't it be nice if we could show this wonderful our pages in a browser?
Update nuts.rb so it also contains something like this:

    module Nuts::Controllers
      class Pages
        def get
          # Only fetch the titles of the pages.
          @pages = Page.all(:select => "title")
          render :list
        end
      end
      
      class PageX
        def get(title)
          @page = Page.find_by_title(title)
          render :view
        end
      end
    end

    module Nuts::Views
      def list
        h1 "All pages"
        ul do
          @pages.each do |page|
            li do
              a page.title, :href => R(PageX, page.title)
            end
          end
        end
      end

      def view
        h1 @page.title
        self << @page.content
      end
    end
  
Here we meet our first _helper_:

    R(PageX, page.title)
  
This is the <em>reversed router</em> and it generates a URL based on a
controller. Camping ships with a few, but very useful, helpers and you can
easily add your owns. Have a look at Camping::Helpers for how you use these.
  
There's a lot of improvements you could do here. Let me suggest:

* Show when the page was created and last updated.
* What happens when the page doesn't exist?
* What should the front page show?
* Add a layout.
* Jazz it up a bit.
 
##The last touch

We have one major flaw in our little application. You can't edit or add new
pages. Let's see if we can fix that:

    module Nuts::Controllers
      class PageX
        def get(title)
          if @page = Page.find_by_title(title)
            render :view
          else
            redirect PageXEdit, title
          end
        end
        
        def post(title)
          # If it doesn't exist, initialize it:
          @page = Page.find_or_initialize_by_title(title)
          # This is the same as:
          # @page = Page.find_by_title(title) || Page.new(:title => title)
          
          @page.content = @input.content
          @page.save
          redirect PageX, title
        end
      end
      
      class PageXEdit
        def get(title)
          @page = Page.find_or_initialize_by_title(title)
          render :edit
        end
      end
    end
  
The core of this code lies in the new <tt>post</tt> method in the PageX
controller. When someone types an address or follows a link, they'll end up at
the <tt>get</tt> method, but you can easily create a form which rather sends
you to the <tt>post</tt> when submitted.

There are other names you can use, but they won't always work. So for now,
don't be fancy and just stick to <tt>get</tt> and <tt>post</tt>. We'll show
you how this really works later.

You might also notice that we use <tt>@input.content</tt>. The
<tt>@input</tt>-hash contains any extra parameters sent, like those in the
forms and those in the URL (<tt>/posts?page=50</tt>).

Here's an <tt>edit</tt>-view, but you can probably do better. See if you can
integrate all of this with what you already have.
  
    module Nuts::Views
      def edit
        h1 @page.title
        form :action => R(PageX, @page.title), :method => :post do
          textarea @page.content, :name => :content,
            :rows => 10, :cols => 50

          br
          
          input :type => :submit, :value => "Submit!"
        end
      end
    end
  

##Phew.

You've taken quite a few steps in the last minutes. You deserve a break. But
let's recap for a moment:

* Always place <tt>Camping.goes :App</tt> at the top of your file.
* Every route ends at a controller, but ...
* ... the controller only delegates the work.
* <tt>@input</tt> contains the extra parameters.
* The views are HTML disguised as Ruby.
* They can access the instances variables (those that starts with a single
  at-sign) from the controller.
* The models allows you to store all kinds of data.
* Place your models before your migrations.
* Helpers are helpful.

Unfortunately, the book stops here for now. Come back in a few months, or join
the mailing list to stay updated, and hopefully there's another chapter
waiting for you.

