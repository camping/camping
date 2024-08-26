# Start a fire with kindling
You know what! Sometimes you just need some ruby to run before you get anything else in your app running. Like starters, or initializers, or fire kindling. Camping offers a feature, named kindling, where we'll run your illustrious scripts.

## How to use kindling
Make a directory next to your `camp.rb` script named **kindling**, This is where you'll put your kindling. Every ruby script in the kindling directory will be executed before camping loads.

Wanna set up some environment variables? Add it to a script in kindling, and you'll run that script before you get **Camping** running.

## Setting up database credentials using kindling
Our built in, very advanced, database integration uses kindling to setup default database credentials, and to load environment variables. Let's add the **dotenv** gem to our **Camping** app to show you how it works. First make a kindilng directory if you don't already have one:
```bash
mkdir kindling
```

Add the **dotenv** gem to your Gemfile:
```ruby
# frozen_string_literal: true
source "https://rubygems.org"

gem 'dotenv', groups: [:development, :test]

gem "camping", "~> 3.2"
# ... other dependencies ... 
```

Make certain to bundle install to get your new gem:
```bash
bundle install
```

Next you'll want to add something special to a new `.env` file. Make a file named `.env`, place it in the root of your camp, next to your camp.rb script:
```
DATABASE_URL=sqlite://camp.db
``` 

Now the last step is to get make some kindling to load the `dotenv` gem code. Make a new file named `dotenv.rb` in the kindling directory and fill it with this:
```ruby
# Load dotenv gem, and get it to load.
require 'dotenv/load'
```

Now you're all set! Environment variables in your `.env` file will now be found in your scripts under the `ENV` array:
```ruby
puts ENV['DATABASE_URL']
# > sqlite://camp.db
```
