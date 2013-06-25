# Views

The view is the scene for our show. The user is sitting in his chair (the
browser) and see on screen actors (the view). Enjoy the show without think
that behind the scenes there is a whole team. The behind the team behind
the cameras is our controller but the user don't care about that...

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
ask for the route /post/1 the controller will be trigged and the get method will
respond with get. 

The first instruction in our controller, will by write the number in the @postn
variable and then "render"

But what is "render". This sentence is no from ruby, this is a camping's sentence
and mean: -show naow the view named (:symbol). It take a symbol as parameter, and
the symbol's name, shall be one of these methods declared in the views. Now we
have only a view named post_number. 

You could "associate" it MENTALLY as a hash like this:

      def post_number => render :post_number

But that will happen in you mind. In camping these will be the modules, not in a hash,
therefore, their are very associated.

## Markaby

A great musician, writer and programmer (and a bit crazy) named
[_why](http://en.wikipedia.org/wiki/Why_the_lucky_stiff) wrote camping.  But
him also wanted , that the user, should have not write HTML code. Him dream
with a world were the programmer write html in their our programming lang.

Therefore, that do not mean: "html knowledge unneeded"

"Write HTML pragmatically" mean: -write html using not html tags. Markaby is a
way for write Hyper Text Markup Language (HTML) using Ruby. Instead of write
that lot of tags, we will write a lot of methods.

If we want to show a <h1> tag, we do not need to write so much exuberant tags
of code.

      h1 'This is a header one'

But that only the beginning, we can do more wild things.

For example: if we want show a table for show users and their real names:

      table do
      th 'User:'
      th 'Realname'
         @users.each do |user,realname|
             tr do
                 td user
                 td realname
             end
         end
      end

However, the @users var, is a Hash declared in the controller. And that user
come from the [model](05_more_about_models.md).

# vim:spelllang=en:spell
