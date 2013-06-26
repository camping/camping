# Views

The view is the scene for our show. The user is sitting in his chair
(the browser) and see on screen actors (the view). Enjoy the show
without think that behind the scenes there is a whole team. The team
behind the cameras is our controller but the user don't care about
that.

The user only see their browser and our application is just and HTML document.


##Camping Views

Inside the Nut::Views module, we will write methods. That method shall called
with the render sentence. The views do not use class.

      module Nust::Views

         def post_number
            p "you asked the post number @postn"
         end

      end

Well, well, that was a views, but now: How we show it to the user? We will call
the view from the controller. And we pass to the view all the parameters that we
want to show.

       module Nuts::Controller
         class PostN
             def get number
               @postn=number
               render :post_number
             end
          end
       end

We just declared a controller for the route /post/(number here). When the browser
ask for the route /post/1 the controller will be trigged and the get
method defined inside the class, will respond to the "get" request in
the web server.

The first instruction in our controller, will by write the number in the @postn
variable and then "render"

But what is `render`? This sentence is not from ruby, this is a camping's
sentence and mean: -show now the view named (:symbol). It take a symbol
as parameter, and the symbol's name, shall be one of these methods
declared in the views. Now we have only a view named post_number.

You could "associate" it MENTALLY as a hash like this:

      def my_view => render :my_view

But that will happen in your mind. In camping these will be happening in
the modules, not in a hash, therefore, their are very associated too.

Imagine your applications as a big building. The controller as the
corridors and the views as the offices. Where are the offices and we do
in each office?

##Views and Controllers

Model View and Controller, are joined but not scrambled. The views use
R(ControllerName) for call the controllers and "move". The controller
will use "render" for call the view.

-And now... what do you thing we have behind the curtains?

   module Why::Controllers
      class CircusCourtains
         def get
            require 'endertromb'
            @monkey=Endertromb::Animals::StartMonkew.new :frog=>true,:place=>:hand
            render :behind_curtain
         end
      end
   end

-OMG! Is a monkey with a start in the hand!

-yes, ladies and gentlemans, we have it just here for you

      module Views
         def behind_curtain
            p @monkey
         end
      end

No, we don't have it behind the curtains, but the user believe it. There
is the view, enjoy the show.

##Template engine

We spoke about the views, and HTML, but we are not using html's tags for
our view...

How happening this?

The rubyst have not necessary to write HTML code. Exists some options
named template. That the "p" before the @monkey in the view. A template
engine is a kind of "pseudo-language" for handle HTML code. In some
template engines you will also write HTML in a more easy way. Their also
handle ruby data inside HTML. Templates engine are the wheels of the
views.

In camping, you will write views using a template engine named
[Markaby](05_more_about_markaby.md) and you will write HTML pragmatically.
