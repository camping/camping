## More about Models

Models are used to persist data. That data could be anything. The balance in a bank account, A list of your favorite restaurants, your blog posts, you name it. Camping uses the *ActiveRecord* Gem, an ORM (object-relational mapper), that maps Database tables to objects.

We define models by inheriting from a base model named Base:

```ruby
class User < Base end
```

Very creative. Base is really just an alias for ActiveRecord, nothing fancy. We put our models into a namespaced module named after our App:

```ruby
Camping.goes :Nuts

module Nuts::Models
    class User < Base end
end
```

Remember from earlier that Models need to be defined before our controllers, otherwise we can't use em. So keep them close to the top.

The new User model we've defined has a small problem, it's completely empty, it doesn't have any data that can be stored in it. Camping models map Database tables to objects automatically, but this model doesn't have a database table yet. To fix that we'll create a migration:

```ruby
Camping.goes :Nuts

module Nuts::Models
    class User < Base; end

    # Define a migration to add users
    class AddUser < V 1.2
        def self.up
            create_table User.table_name do |t|
                t.string :username
                t.string :email
                t.timestamps
            end
        end

        def self.down
            drop_table User.table_name
        end
    end
end
```

Databases, like birds, migrate. Migrations move our database from one configuration to another. In our case we're adding users. So cool. User's should be able to log in, sign up, maybe make some pages. We could make the next myspace. To get our database to make a users table we need force our app to create the schema.

```ruby
def Nuts.create
    Nuts::Models.create_schema
end
```

Now that puppy will migrate when we launch our app.

Our Users now have greater hope to survive. So great. I love it.
