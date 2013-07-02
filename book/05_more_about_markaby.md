##Where Markaby's come from

A great musician, writer and programmer (and a bit crazy) named
[_why](http://en.wikipedia.org/wiki/Why_the_lucky_stiff) wrote camping.  Before
banish himself to the dimension from where him come (a place named "the
keyhole"); hi also wanted, that the developers, should have not write pure HTML
code. Him dream with a world were the programmer write html in their
programming language.

Rails users are very hard guys. Their eat the soup using a fork and generate
HTML views in a template engine named Erb. Their use a long set of weird tools
for generate that Embedded Ruby (erb), their call it "scaffolding". The basic
idea is: "let me rails write html code for you" Many framework have in the
README a line that say: "support more populars template engines" but normally
peoples uses the default in the framework.

"Mab" is the template engine used by default in camping. _why Wrote the first
implementation named Markaby and then, judofyr and Jenna, power-up markaby
writing a more compact version of it.

While you are writing with mab, will see ruby code front you are eyes, but your
mind, will be seen pure HTML without tags. We will be "metaprograming HTML
code". In order to show a Header-1 tag, we just call a method named h1 and send
the content as parameter. It will make the dirty work writing all the tags just
like this:

      h1 'This is a header one'

"Write HTML pragmatically" mean: -write html using not html tags.
Markaby is a way for write Hyper Text Markup Language (HTML) using Ruby.
That do not mean "html knowledge unneeded"

But that is only the beginning, we can do more wild things.

##Writing HTML pragmatically

For example: if we want show a table for show users and their real
names:

         # call me using render :users 
         # from a get in the controllers
         def users
            table do
            th 'User'
            th 'Realname'
               @users.each do |user,realname|
                  tr do
                       td user
                       td realname
                  end # tr
               end # each
            end # table
         end # def

Take a look better [here](https://github.com/camping/mab/blob/master/README.md)

##Markaby and the layout

There is a special view named "layout". The layout, is view that will be
rendered each time any other view are rendered. In fact, the layout will take
the other views for compose himself. The layout is rendered before anything.

Each time you use the "render" sentence, you will be rendering the
layout and the desired view. Because that, wee need some "special"
tweaks in the layout. It must have a door with a poster that say:
"other view will enter using this door"

The layout will be rendered, and in some place you will put the other view.
This will be done with the "yield" sentence. Put the yield sentence whenever
you want rendering all the other views.

This is very useful, for example: We wan to write a footer in ALL the
pages that we are rendering. You can write the footer in every views
definition, or just write the footer in the layout.

Without a layout, if you render the table's views. Camping will drop out the
table just like that to the browser's render. It will not draw any body or head
tag. Writing body and head in every page could be a very bored task. But do not
worry, the layout is here.

Lets write our layout, with all the HTML shape and including a footer

            def layout
            
              html do 
                head do
                  title 'My Blog'
                end

                 body do
                  
                  div.wrapper! do
                    self << yield
                 end
                  
                  p.footer! do
                    text 'Powered by Camping'
                 end
                end
              end

            end # layout

Well, that was wild. Let's see: First we have everything inside a block, the
html's block. At the next level, the first block is head, that is rendering
something like:

            <html>
               <head>
                  <title> My Blog </title>
               </head>
            </html>

If you look at the HTML's source of camping, you will see a VERY LOOOONG
line with every the HTML code, better do not look it.

Then, come the more weird thing. A div with a estrange sentence:

         self << yield
         
That mean: -put just right here, the other view called.

In that place, in the center of the div.wrapper, will be placed all our
views called using render's sentence.

When you call: 

            render :someview

Camping will rendering before, the layout view, and put all the content
of "someview" inside div.wrapper! You shall not write a lot of tag like
head or title.

Finally, it will be rendering a "p" named footer. That will be the footer in
all our pages.

##Tip

What would happen? If you do this in the layout:

                head do
                  title "#{@title}"
                end

Hummm... You could "rewrite" the titles of each pages. In the
controller, you just need to declare the variable @title, and that will
be the title for that page.

Remember: 

* Views take @variables from the controller
* Layout is rendered before any called view.
* Markaby is ruby code and it can be embedded
* View's modules use not `class` declarations

In the table example, we used a hash named @users. But. Where come from all
thats data? 

It come from the controller, but the controller took it from the
[model](06_more_about_models.md). The M of the MVC, the layer who stare
the whole bunch of persistent data.
