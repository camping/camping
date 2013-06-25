# Controllers

What are these `controllers`? It is a good question for a newb. In the [MVC
paradigm](http://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller#Overview)
a Models could be described as a very weird and hard to understand thing.

When you look in the browsers navigation's bar, you will see something like:

`http://localhost:3301/welcome/to/my/site`

The Universal Resource Locator (URL) is showing you a "structured" web site
running inside a server that listening in the 3301's port. The site's internals
routes is "drawing" the path: Inside the root_dir/ are the directory /welcome/
an it content recursive the some others dirs: "to", "my" and "site"(./to/my/site)

But that is virtual, the site have not really a directory structure like that...
That would be useless. The site use a "routes drawing system" for get a _control_
of that routes and that is what *the controller* does.

##Camping Routes and Controllers

In camping, each `"capitalized"` word is like the slash. For example:

      WelcomeToMySite

Shall draw a route like:

      /welcome/to/my/site

Or you could use instead the weird R for get more control in your routes

      Welcome < R '/welcome/to/my/site'

All of this will be declared inside the Nuts::Controllers module

##Controllers Parameters

Controllers can also handle your application's parameters. For example
when the client ask four a route like /post/1 the static web server shall
look out for the dir number 1 and serve the content. It should have a
lot of "number-named" directories for do that simple job.

But the controller, draw a dynamic path for every asked post. Wee just need
to tell him about the size of the flock.

In camping, the N and the X in a controller's declaration, mean a parameter:

      class PostN

Will trigger the /post route and any number after it. For exmaple, 

      /post/1
      /post/99

But it will not, math against a word. For example, if asking /pots/mypost
it will return 404. Because the PostN only math _Numeric_ parameters.

If you like to math anything else, you should write a controller like:

      class PostX

The _X_ mean: -math anything, including number and words. It will math:

      /post/1
      /post/99
      /post/mypost

But it will NOT math: /post/mypost/1 or anything that could have a slash.
Because a "/" mean: "the next directory", and that is another Capitalized word.

##Getting parameter from the controller

Ok, we have the controller that match parameters; and now what?

You will like to show the post number N asked in the controller. You need the
number.

      class PostN
          def get number
               p "the parameter was: #{number}"
          end
      end

Please, do not try that at home, is very dirty using a view inside the controller.

The method get, for the /post/N route, will take a parameter. That number will by
inside the "number parameter". From now, if you like to route something to you
post route, you will write a link 100% pragmatically like this:

      @post=rand 1..9
      a "See the post number: #{@post}",:href=>R(PostN,@post)

For that example, we just, choose a random post and then show a link for follow
the path.

-but you told me that should now write that thing in the controller

Yep... I told. The things like that, are views, because that thats part, will
be in the user's face. Our client will not see the controllers, their view,
the [views](04_more_about_views.md).
