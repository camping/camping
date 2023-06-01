require 'zeitwerk'
require 'listen'

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
  class Loader
    attr_reader :file

    def initialize(file=nil, &blk)
      @file = file
      @mtime = Time.at(0)
      @requires = []
      @apps = {}
      @callback = blk
      @root = Dir.pwd
      @file = @root + '/camp.rb' if @file == nil
      loader = Zeitwerk::Loader.new

      # setup Zeit for this reloader
      # setup_zeit(loader)

      # setup recursive listener on the apps and lib directories from the source script.
      @listener = Listen.to("#{@root}/apps", "#{@root}/lib", "#{@root}") do |modified, added, removed|
        @mtime = Time.now
        reload!
      end
      @listener.start
    end

    def name
      @name ||= begin
        base = @file.dup
        base = File.dirname(base) if base =~ /\bconfig\.ru$/
        base.sub!(/\.[^.]+/, '')
        File.basename(base).to_sym
      end
    end

    # remove_constants called inside this.
    def load_everything(old_constants)
      all_requires = $LOADED_FEATURES.dup
      all_apps = Camping::Apps.dup

      load_file
      reload_directory("#{@root}/apps")
      reload_directory("#{@root}/lib")
      Camping.make_camp
    ensure
      @requires = []
      new_apps = Camping::Apps - all_apps

      @apps = new_apps.inject({}) do |hash, app|
        if file = app.options[:__FILE__]
          full = File.expand_path(file)
          @requires << [file, full]
        end

        key = app.name.to_sym
        hash[key] = app

        apps.each do |app|
          @callback.call(app) if @callback
          app.create if app.respond_to?(:create)
        end

        hash
      end

      ($LOADED_FEATURES - all_requires).each do |req|
        full = full_path(req)
        @requires << [req, full] # if dirs.any? { |x| full.index(x) == 0 }
      end

      @mtime = mtime

      self

    end

    # load_file
    #
    # Rack::Builder is mainly used to parse a config.ru file and to
    # build a rack app with middleware from that.
    def load_file
      if @file =~ /\.ru$/
        @app = Rack::Builder.parse_file(@file)
      else
        load(@file)
      end
      @requires << [@file, File.expand_path(@file)]
    end

    # removes all constants recursively included using this script as a root.
    # so everything in /apps, and /lib in relation from this script.
    def remove_constants
    	@requires.each do |(path, full)|
     		$LOADED_FEATURES.delete(path)
     	end

      @apps.each do |name, app|
        Camping::Apps.delete(app)
        Object.send :remove_const, name
      end.dup
    ensure
      @apps.clear
      @requires.clear
    end

    # Reloads the file if needed.  No harm is done by calling this multiple
    # times, so feel free call just to be sure.
    def reload
      return if @mtime >= mtime rescue nil
      reload!
    end

    def reload!
      load_everything(remove_constants)
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

    # sets up Zeit autoloading for the script locations.
    def setup_zeit(loader)
	    loader.push_dir("#{@root}/apps") if Dir.exist?("#{@root}/apps")
	    loader.push_dir("#{@root}/lib") if Dir.exist?("#{@root}/lib")
	    if ENV['environment'] == 'development'
	      loader.enable_reloading unless ENV['environment'] == 'production'
	    end
	    loader.setup
    end

    # Splits the descendent files and folders found in a given directory for eager loading and recursion.
    def folders_and_files_in(directory)
      directory = directory + "/*" # unless directory
      [Dir.glob(directory).select {|f| !File.directory? f },
      Dir.glob(directory).select {|f| File.directory? f }]
    end

    # Reloads a directory recursively. loading more shallow files before deeper files.
    def reload_directory(directory)
      files, folders = folders_and_files_in(directory)
      files.each {|file|
        @requires << [file, File.expand_path(file)]
        load file
      }
      folders.each {|folder|
        reload_directory folder
      }
    end

    def mtime
      @requires.map do |(path, full)|
        File.mtime(full)
      end.reject {|t| t > Time.now }.max || Time.now
    end

    # Figures out the full path of a required file.
    def full_path(req)
      return req if File.exist?(req)
      dir = $LOAD_PATH.detect { |l| File.exist?(File.join(l, req)) }
      if dir
        File.expand_path(req, File.expand_path(dir))
      else
        req
      end
    end
  end
end
