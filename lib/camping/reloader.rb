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
    attr_reader :file
    
    def initialize(file, &blk)
      @file = file
      @mtime = Time.at(0)
      @requires = []
      @apps = {}
      @callback = blk
    end

    def name
      @name ||= begin
        base = @file.dup
        base = File.dirname(base) if base =~ /\bconfig\.ru$/
        base.sub!(/\.[^.]+/, '')
        File.basename(base).to_sym
      end
    end
    
    # Loads the apps availble in this script.  Use <tt>apps</tt> to get
    # the loaded apps.
    def load_apps(old_apps)
      all_requires = $LOADED_FEATURES.dup
      all_apps = Camping::Apps.dup

      load_file
    ensure
      @requires = []
      dirs = []
      new_apps = Camping::Apps - all_apps
      
      @apps = new_apps.inject({}) do |hash, app|
        if file = app.options[:__FILE__]
          full = File.expand_path(file)
          @requires << [file, full]
          dirs << full.sub(/\.[^.]+$/, '')
        end

        key = app.name.to_sym
        hash[key] = app
        
        if !old_apps.include?(key)
          @callback.call(app) if @callback
          app.create if app.respond_to?(:create)
        end

        hash
      end

      ($LOADED_FEATURES - all_requires).each do |req|
        full = full_path(req)
        @requires << [req, full] if dirs.any? { |x| full.index(x) == 0 }
      end

      @mtime = mtime
      
      self
    end

    def load_file
      if @file =~ /\.ru$/
        @app,_ = Rack::Builder.parse_file(@file)
      else
        load(@file)
      end
    end
    
    # Removes all the apps defined in this script.
    def remove_apps
      @requires.each do |(path, full)|
        $LOADED_FEATURES.delete(path)
      end

      @apps.each do |name, app|
        Camping::Apps.delete(app)
        Object.send :remove_const, name
      end.dup
    ensure
      @apps.clear
    end
    
    # Reloads the file if needed.  No harm is done by calling this multiple
    # times, so feel free call just to be sure.
    def reload
      return if @mtime >= mtime rescue nil
      reload!
    end

    def reload!
      load_apps(remove_apps)
    end
    
    # Checks if both scripts watches the same file.
    def ==(other)
      @file == other.file
    end

    def apps
      if @app
        { name => @app }
      else
        @apps
      end
    end
    
    private
    
    def mtime
      @requires.map do |(path, full)|
        File.mtime(full)
      end.reject {|t| t > Time.now }.max || Time.now
    end
    
    # Figures out the full path of a required file. 
    def full_path(req)
      return req if File.exists?(req)
      dir = $LOAD_PATH.detect { |l| File.exists?(File.join(l, req)) }
      if dir 
        File.expand_path(req, File.expand_path(dir))
      else
        req
      end
    end
  end
end
