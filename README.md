![Build Status](https://github.com/camping/camping/actions/workflows/camping.yml/badge.svg) ![Build Status](https://github.com/camping/camping/actions/workflows/integration.yml/badge.svg)

# ⛺️ Camping, a Microframework

Camping is a micro web framework which stays as small as possible.
You can probably view the complete source code on a single page. But, you
know, it's so small that, if you think about it, what can it really do? Apparently
it can do a lot. It's pretty swell.

The idea here is to store a complete fledgling web application in a single
file like many small CGIs. But to organize it as a Model-View-Controller
application. And with time, you can move your Models, Views, and Controllers into
other files as your app grows.

Camping supports multiple *apps*, capsuled code that runs together. Each app can
have independent models, routes, and controllers.

Pack your gear when you go Camping! With a simple plugin system, Camping is easily
extensible. Add all sorts of useful and silly things.

## A Camping Skeleton

A skeletal Camping blog could look like this:

```ruby
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
```

## Installation

Interested yet?  Luckily it's quite easy to install Camping.  We'll be using
a tool called RubyGems, and Bundler, so if you don't have that installed
yet, go grab it! Once that's sorted out, open up a Terminal or Command
Line and enter:

```
gem install camping
```

~~Even better, install the Camping Omnibus, a full package of recommended libs:~~ Camping Omnibus will return for summer vacation.

Now make a new directory filled with your camp essentials using the `camping new` command:

```
camping new Donuts # You can replace Donuts with whatever but CamelCased.
```

Move to your new directory, then use bundler to install all of your camp's dependencies:

```
cd donuts; bundle install
```

You can now run camping using the `camping` command. We recommend running camping in development mode locally. Make certain to prefix the camping command with `bundle exec` to run your app with the gems you've installed just for your camp:

```
bundle exec camping -e development
```

## Learning

First of all, you should read [the first chapters](/book/01_introduction.md)
of The Camping Book. It should hopefully get you started pretty quick. While
you're doing that, you should be aware of the _reference_ which contains
documentation for all the different parts of Camping.

[The wiki](https://github.com/camping/camping/wiki) is the place for all tiny,
useful tricks that we've collected over the years.  Don't be afraid to share
your own discoveries; the more, the better!

We have a Discord channel over at the Ruby Punks community, so if you feel
like chatting with us, you should join [#camping](https://discord.gg/JSmPBsWgFt). Once our chattin' leads to action, we open up an issue on Github and move the conversation over there.

## Contributing

Camping is under active development, and we'd love some help!. Our current focus is bug fixes, documentation, and tests. We have a [number of issues](https://github.com/camping/camping/issues?q=is%3Aissue+is%3Aopen+label%3A%22Great+for+new+Contributors%22) open for new contributors to get crackin!

To begin contributing, [Fork Camping](https://github.com/camping/camping/fork), Then make a new branch, (`git checkout -b my_branch_name`) with your changes. When you're ready to bring all that hard work on over, open a draft PR and ping Karl to take a look, He'll help you fix any issues and help you get it inside of old Camping.

Have a suggestion? Open an issue with what you think we ought to be doing with our lives, and we'll talk about it. Don't be shy.

## Running Tests

Tests should be run using bundler and rake: `bundle exec rake`.

## Minting Releases

We use Ruby Gems to distribute versions of Camping. When you're ready to mint a release, run: `gem build -o camping.gem`, then `gem push camping.gem`.

## Authors

Camping was originally crafted by [why the lucky stiff](http://en.wikipedia.org/wiki/Why_the_lucky_stiff), but is now maintained by the _community_. This simply means that if we like your patch, it will be applied. Everything is managed through this Github repo, so just [open an issue](https://github.com/camping/camping/issues/new) and you can instantly take part in shaping Camping.
