Once you've built your Camping app, you'll almost certainly want to get it online some place, so others can get at it! There are tons of ways to do this, some easy, some hard, some free, and some expensive. Some of these techniques also come with limitations.

# Using a Rackup compatible host
First make a config.ru file and fill it with goodies:
```ruby
# config.ru
require 'camping'
require 'camping/server'

Camping::Server.start
```

If your app has any settings, like the port number, or the file where your camping app is located if it's not camp.rb, then pass those along as a hash:
```ruby
# config.ru
require 'camping'
require 'camping/server'

Camping::Server.start({
  :script => 'blog.rb',
  :port => '80'
})
```

# Using a spare computer
Cost: Usually free; Limitations: None really; Extra Requirements: Need to have a computer you can leave on all the time.

This is probably the easiest way. Just find a computer you can leave on all the time, and use The Camping Server on Port 80, by running something like this in the Command Prompt or Terminal:

```
camping --port 80 myapp.rb
```

Then check to make sure it's working by visiting http://localhost:80/ on that computer. Next, you'll need to find out if your internet provider gives you a Static IP address, or a Dynamic IP. Most home internet providers give you a Dynamic IP, where most business accounts come with a Static IP. If you don't know, you can find out by phoning your internet provider.

# If you have a static IP address
This is really a great situation to be in. You'll next want to get a domain name of some sort. You can register one on a Domain Name Registrar, but this will generally cost about $12 per year to keep. You can also get a free subdomain name from services like afraid.org. Regardless how you do it, you'll want to create an A Record, and for it's value, provide your IP address. You can usually find out your IP address by visiting an IP Lookup Website, or by asking your Internet Provider.

# If you have a dynamic IP address
Your IP Address will change from time to time, so you'll need to use a Dynamic DNS service. Popular DDNS services include Afraid.org, DynDNS, and No-IP. These will either require you to run a little program on your computer to watch when your IP changes and update the domain name, or have you enter a special username and password in to certain home routers.


# Troubleshooting
If you find others can't access your website through the domain name, and you have a dynamic IP, your Internet Provider might be applying Port Blocking. If you phone them, they might be able to remove the blocks. Otherwise, you'll need to run the camping server on a different port. 8080 is a common alternative. Of note, you'll need to include :8080 (or whatever) after the domain name and before the slash in your web address for this to work. For example: http://funkytown.afraid.org:8080/ - otherwise, make sure the DDNS updating software is running and working correctly.

# Using Dreamhost
Cost: About $5 per month; Limitations: None really; Extra Requirements: SFTP or FTP software, and an SSH client like PuTTY on windows, or the Terminal on Linuxes and Mac OS.

Dreamhost have some really cheap hosting plans, and are quite easy to use. They include support for Rack on their shared hosting plans, and are fairly reliable and fast.

Enable the "Passenger (Ruby/Python apps only):" option in a domain's settings, from the Manage Domains page within the Dreamhost Panel. Ensure the "Shell account - allows SFTP/FTP plus ssh access." option is enabled on your main user, from the Manage Users page. Use your SSH software to login, and if you haven't already, set up rubygems. Once that's done, it's time to install stuff!

```
gem install camping-omnibus
```

Install any other gems you might need for your app, then use your SFTP or FTP software to upload the file to the folder labeled with your domain's name. Lastly, you'll need to add a few things:

A folder called 'tmp', containing a file called 'restart.txt', which you'll need to change whenever you need to make Dreamhost reload your app's source code (while you're trying things out, you can change this filename to 'always_restart.txt' to reload the app with each request).

A file called config.ru, containing something like:

```ruby
require 'rubygems'
ENV['GEM_PATH'] = File.join(File.dirname(__FILE__), '..', '.gems') if File.exist?('/dh')
Gem.clear_paths
require 'rack'
require 'blog.rb'

use Rack::ShowExceptions # optional, but helpful if there's any errors

Blog.create if Blog.respond_to? :create
run Blog
```

Make sure it's all uploaded, and your app should be online! Yay!

# Using Heroku
Cost: None for small apps; Limitations: Cannot change files in the filesystem, must use database; Extra Requirements: Need to install and use git to upload your app to the Heroku servers.

Someone should really add stuff to this section. For now, see How to run Camping 2.0 apps on Heroku or Heroku's own guide for Rack-based apps (scroll down for Camping).

# Using Google App Engine
Cost: None for small apps; Limitations: Cannot change files in the filesystem, must use the google database; Extra Requirements: ???.

Someone should also add information to this section. It's possible using jRuby somehow. I imagine this guide would help a lot!

# Using a CGI Webhost
Firstly, make sure your webhost can run ruby apps. Most can, thankfully. If you have shell access, you can check by entering 'which ruby' and seeing if it finds anything. Unfortunately, different webhosts work differently, so we can't provide specific instructions for installing rubygems on your webhost. If all else fails, you can extract the files from the lib folder within each gem, put the files in a folder, and add the big folder to your load path. Once you've done this, you'll just need to make sure your camping app file starts with:

```ruby
#!/usr/bin/ruby
```

And then either the simple postamble, or the complex postamble:

```ruby
# Plug it in to CGI
Rackup::Handler::CGI.run(Blog)) if __FILE__ == $0
```

Then upload it to your server, and change the file's permissions to have all the executable bits set. You should now be able to visit the file using your web browser (for example, http://example.com/blog.rb). In fact, you don't even need the .rb. the #!/usr/bin/ruby line lets your server know what kind of file it is. :)


# Using a Rack Compatible Web Host

Follow your Webhost's instructions, and in the config.ru file, add a little something like this:

```ruby
... require 'blog' run Blog end
```

To set up Passenger and Rack for really easy deployment under Apache or Nginx see the screencasts on the Passenger site. If you have (e.g.) Apache on your computer, this is also good for local testing too.

You can also use Rack::URLMap to plug a whole bunch of different apps in to one folder. A camping app here, a rails project there, a sinatra doodad over there in the corner messing up the whole global namespace. The possibilities are severely limited!

# And Also Some Luck
We wish you good luck! Publishing your app to a server can be an annoying experience the first time you do it. Often little bugs will appear you never noticed before on your computer, or things just might not work for mysterious reasons. Stick to it, and don't be afraid to ask for help from those more battle hardened.
