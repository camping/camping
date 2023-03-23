# Controllers

What are these _controllers_? This is a good question for a Camping newb. In the [MVC
paradigm](http://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller#Overview)
a Models could be described as a very weird and hard to understand thing.

When you look in the browser's navigation bar, you will see something like:

`http://localhost:3301/welcome/to/my/site`

The Universal Resource Locator (URL) is showing you a "structured" web site
running inside a server that listening in the `3301` port. The site's internal
routes are "drawing" the path: Inside the `root_dir/` is the directory `/welcome/`
and it recursively adds the names of the deeper directories: "to", "my", and "site" (`./to/my/site`).

But that is virtual, the site doesn't really have a directory structure like that...
That would be useless. The site uses a "route drawing system" to get _control_
of that route; this is what *the controller* does.

## Camping Routes and Controllers

In camping, each _capitalized_ word in a camel-cased contoller declaration is like the
words between each slash in a URL. For example:

```ruby
WelcomeToMySite
```
will draw the route:

```
/welcome/to/my/site
```

Or you could instead use the weird R helper to get more specific control of your routes:

```ruby
Welcome < R '/welcome/to/my/site'
```

All of this will be declared inside the Nuts::Controllers module.

## Controller Parameters

Controllers can also handle your application's parameters. For example,
when the client asks for a route like `/post/1`, a static web server would
look out for the directory named "1" and serve the content in that directory.
It would need a lot of "number-named" directories to do that simple job.

But in our case, the controller draws a dynamic path for every asked post. We just need
to tell him about the size of the flock.

In camping, adding `N` or `X` to a controller's declaration tells it to expect a parameter.
The `N` suffix, which will match a numbered route, is declared like this:

```ruby
class PostN
```

With this controller, adding a number to the simple `/post` route in your browser will trigger this route. For example,
either of these will work:

```
/post/1
/post/99
```

But this `N` route will not match against a word. For example, a request for `/pots/mypost`
will return 404 (Not Found). Because the `PostN` declaration will only match _Numeric_ parameters.

If you would like to match something other than a number, you should use the `X` suffix:

```ruby
class PostX
```

The _X_ tells the controller to match anything, including number and words. For example, it will match:

```
/post/1
/post/99
/post/mypost
```

But it will NOT match: `/post/mypost/1` (or anything that has "/" in the name). Since slashes signify
deeper directories, you would need to tell the controller to recognize the deeper directory before using a parameter.
You can do this using camel case, followed by the "X" or "N":

```ruby
class PostMypostX
```

## Getting parameters from the controller

Ok, we have the controller that match parameters; and now what?

Say that you want to show the post number N requested in the controller. You'll need the
number.

```ruby
class PostN
    def get number
        p "the parameter was: #{number}"
    end
end
```

Please, do not try that at home. It's very dirty to use a _view_ inside the controller (more on that soon).

The method `get`, for the `/post/N route`, will take a parameter. That number will by
inside the "number parameter". From now, if you want to route something to your
post route, you can write a link 100% pragmatically like this:

```ruby
@post=rand 1..9
a "See the post number: #{@post}",:href=>R(PostN,@post)
```

For that example, we just choose a random post and then displayed a link to its path.

> but you told me that I shouldn't write that in the controller...

Yep...I said that. These things are called "views" because they will
be in the user's face. Our client will not see the controllers; they will be hidden from them when they visit our site.
Our client will only see the [views](04_more_about_views.md).
