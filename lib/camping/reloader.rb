module Camping
  # == The Camping Reloader
  #
  # Camping apps are generally small and predictable.  Many Camping apps are
  # contained within a single file.  Larger apps are split into a handful of
  # other Ruby libraries within the same directory.
  #
  # Since Camping apps (and their dependencies) are loaded with Ruby's require
  # method, there is a record of them in $LOADED_FEATURES.  Which leaves a
  # perfect space for this class to manage auto-reloading an app if any of its
  # immediate dependencies changes.
  #
  # == Wrapping Your Apps
  #
  # Since bin/camping and the Camping::Server class already use the Reloader,
  # you probably don't need to hack it on your own.  But, if you're rolling your
  # own situation, here's how.
  #
  # Rather than this:
  #
  #   require 'yourapp'
  #
  # Use this:
  #
  #   require 'camping/reloader'
  #   reloader = Camping::Reloader.new('/path/to/yourapp.rb')
  #   blog = reloader.apps[:Blog]
  #   wiki = reloader.apps[:Wiki]
  #
  # The <tt>blog</tt> and <tt>wiki</tt> objects will behave exactly like your
  # Blog and Wiki, but they will update themselves if yourapp.rb changes.
  #
  # You can also give Reloader more than one script.
  class Reloader
    attr_reader :scripts, :apps
    
    # This class is doing all the hard work; however, it only works on
    # single files.  Reloader just wraps up support for multiple scripts
    # and hides away some methods you normally won't need.
    class Script # :nodoc:
      attr_reader :apps, :file, :dir, :extras
      
      def initialize(file, callback = nil)
        @file = File.expand_path(file)
        @dir = File.dirname(@file)
        @extras = File.join(@dir, File.basename(@file, ".rb"))
        @mtime = Time.at(0)
        @requires = []
        @apps = {}
        @callback = callback
      end
      
      # Loads the apps availble in this script.  Use <tt>apps</tt> to get
      # the loaded apps.
      def load_apps
        @requires.each do |path|
          $LOADED_FEATURES.delete(path)
        end

        all_requires = $LOADED_FEATURES.dup
        all_apps = Camping::Apps.dup
        
        begin
          load(@file)
        rescue Exception => e
          puts "!! Error loading #{@file}:"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace
          puts "!! Error loading #{@file}, see backtrace above"
        end
        
        @requires = ($LOADED_FEATURES - all_requires).map do |req|
          full = full_path(req)
          full if full == @file or full.index(@extras) == 0
        end
        
        @mtime = mtime
        
        new_apps = (Camping::Apps - all_apps)
        old_apps = @apps.dup
        
        @apps = new_apps.inject({}) do |hash, app|
          key = app.name.to_sym
          hash[key] = app
          
          if !old_apps.include?(key)
            @callback.call(app) if @callback
            app.create if app.respond_to?(:create)
          end
          hash
        end
        
        self
      end
      
      # Removes all the apps defined in this script.
      def remove_apps
        @apps.each do |name, app|
          Camping::Apps.delete(app)
          Object.send :remove_const, name
        end
      end
      
      # Reloads the file if needed.  No harm is done by calling this multiple
      # times, so feel free call just to be sure.
      def reload!
        return if @mtime >= mtime
        remove_apps
        load_apps
      end
      
      # Checks if both scripts watches the same file.
      def ==(other)
        @file == other.file
      end
      
      private
      
      def mtime
        (@requires + [@file]).compact.map do |fname|
          File.mtime(fname)
        end.reject{|t| t > Time.now }.max
      end
      
      # Figures out the full path of a required file. 
      def full_path(req)
        dir = $LOAD_PATH.detect { |l| File.exists?(File.join(l, req)) }
        if dir 
          File.expand_path(req, File.expand_path(dir))
        else
          req
        end
      end
    end

    # Creates the reloader, assigns a +script+ to it and initially loads the
    # application.  Pass in the full path to the script, otherwise the script
    # will be loaded relative to the current working directory.
    def initialize(*scripts)
      @scripts = []
      @apps = {}
      update(*scripts)
    end
    
    def on_reload(&blk)
      @callback = blk
    end
    
    # Updates the reloader to only use the scripts provided:
    #
    #   reloader.update("examples/blog.rb", "examples/wiki.rb")
    def update(*scripts)
      old_scripts = @scripts.dup
      clear
      
      @scripts = scripts.map do |script|
        file = File.expand_path(script)
        old_scripts.detect { |s| s.file == file } or
        Script.new(script, @callback)
      end
      
      reload!
    end
    
    # Removes all the scripts from the reloader.
    def clear
      @scripts = []
      @apps = {}
    end
    
    # Returns the script which provided the given app.
    def script(app)
      @scripts.each do |script|
        return script if script.apps.values.include?(app)
      end
      
      false
    end
    
    # Simply calls reload! on all the Script objects.
    def reload!
      @apps = {}
      @scripts.each do |script|
        script.reload!
        @apps.update(script.apps)
      end
    end
  end
end
