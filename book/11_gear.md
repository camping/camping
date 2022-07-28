# Pack Your Gear
Camping provides a way to include and expand Camping without messing with it's innards too much, we call these plugins gear.

To use gear you need to *pack* it into camping:

```ruby
Camping.goes :Blog

module Blog
  pack Camping::Gear::CSRF
end

# or

Blog.pack Camping::Gear::CSRF
```

Define your gear by opening a module:
```ruby
module Royalty
  def queens
    @queens ||= [ "Beyonce", "Niki", "Doja"]
  end
end
```

Gear define methods and helpers that are included in your app. Define a `ClassMethods` module to have class methods included:
```ruby
module Royalty
  module ClassMethods
    def secret_sauce
      @_secret_sauce ||= SecureRandom.base64(32)
    end
  end
  # /...
end
```

You can also supply a setup callback method that runs after your gear is packed:
```ruby
module Royalty
  # Run a setup routine with this Gear.
  def self.setup(app)
    @app = app
    @app.set :saucy_secret, "top_secret_sauce"
  end
end
```

We'll be adding some really great gear soon. In the meantime, try making your own gear.
