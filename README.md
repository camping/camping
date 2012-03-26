[![Build Status](https://secure.travis-ci.org/camping/camping.png)](http://travis-ci.org/camping/camping)

#Camping, a Microframework

Camping is a web framework which consistently stays at less than 4kB of code.
You can probably view the complete source code on a single page. But, you
know, it's so small that, if you think about it, what can it really do?

The idea here is to store a complete fledgling web application in a single
file like many small CGIs. But to organize it as a Model-View-Controller
application like Rails does. You can then easily move it to Rails once you've
got it going.

##A Camping Skeleton

A skeletal Camping blog could look like this:

    require 'camping'
  
    Camping.goes :Blog

    module Blog::Models
      class Post < Base; belongs_to :user; end
      class Comment < Base; belongs_to :user; end
      class User < Base; end
    end

    module Blog::Controllers
      class Index
        def get
          @posts = Post.find :all
          render :index
        end
      end
    end

    module Blog::Views
      def layout
        html do
          head { title "My Blog" }
          body do
            h1 "My Blog"
            self << yield
          end
        end
      end

      def index
        @posts.each do |post|
          h1 post.title
        end
      end
    end
  
##Installation

Interested yet?  Luckily it's quite easy to install Camping.  We'll be using
a tool called RubyGems, so if you don't have that installed yet, go grab it!
Once that's sorted out, open up a Terminal or Command Line and enter:

    gem install camping

Even better, install the Camping Omnibus, a full package of recommended libs:

    gem install camping-omnibus --source http://gems.judofyr.net

If not, you should be aware of that Camping itself only depends on
[Rack](http://rack.rubyforge.org), and if you're going to use the views you also
need to install **[markaby](http://markaby.github.com/)**, and if you're going to use the database you need
**activerecord** as well.

    gem install markaby
    gem install activerecord
 
##Learning

First of all, you should read [the first chapters](camping/blob/master/book/01_introduction.md)
of The Camping Book. It should hopefully get you started pretty quick. While
you're doing that, you should be aware of the _reference_ which contains
documentation for all the different parts of Camping.

[The wiki](http://wiki.github.com/camping/camping) is the place for all tiny,
useful tricks that we've collected over the years.  Don't be afraid to share
your own discoveries; the more, the better!

And if there's anything you're wondering about, don't be shy, but rather 
subscribe to [the mailing list](http://rubyforge.org/mailman/listinfo/camping-list)
and ask there.  We also have an IRC channel over at Freenode, so if you feel
like chatting with us, you should join [#camping @ irc.freenode.net](http://java.freenode.net/?channel=camping).

##Authors

Camping was originally crafted by [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff),
but is now maintained by the _community_.  This simply means that if we like your
patch, it will be applied.  Everything is managed through [the mailing list](http://rubyforge.org/mailman/listinfo/camping-list),
so just subscribe and you can instantly take a part in shaping Camping.