Middleware in Camping is just Rack Middleware, and if you're familiar with Rack middleware then you'll be right at home. I'm going to assume that you have no idea what Rack or Rack middleware *is*, Let's learn about it.

# The HTTP Request

The web works in a request -> response pattern. When we *GO* to a webpage our browser is making a *request* to a web server. That request is processed and a *response* is sent. We have already covered how a response is mapped to our ruby code through controllers in Chapter 3. Those responses could be any of a number of things, HTML, an image, JSON, CSS, Web servers are pretty capable. When using Camping you'll generally respond with HTML, CSS, or Javascript, maybe some images.

As that request passes through your application you may need to make some decisions about it. Does the request try to get something with restricted access? Is it a request to a dynamic or cached file? Whatever it is we can write some Ruby code to make some decisions about that request before passing it along to Camping's router. That's what Middleware is for.

Middleware is Rack based and follows Rack Middleware conventions. Write a class, name it whatever you want but it must have an `#initialize` and a `#call` method.

```ruby
class MyMiddleware
  def initialize(app)
    @app = app
  end
  def call(env)
    status, headers, body = @app.call(env)
    [status, headers, body]
  end
end
```

The `#initialize` method must store a reference to an `app` object that is passed in as a parameter. The `#call` method accepts an environment parameter that we call `env` and returns an array with 3 values: `status`, `headers`, and `body`. Now, when I first saw this I was confused, why do we immediately Call


### notes:
* really good railscast about it that's like... 13 years old: http://railscasts.com/episodes/151-rack-middleware?autoplay=true
* An extremely old article about it: https://web.archive.org/web/20150105094611/https://www.amberbit.com/blog/2011/07/13/introduction-to-rack-middleware/
