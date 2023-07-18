require 'rack'
require 'rack/utils'
require 'rack/common_logger'
require 'Logger'

module Gear
  module Firewatch

    @logger = nil

    class << self

      def included(mod)
        # mod.extend(ClassMethods)
        mod.const_get(:Helpers).include(HelperMethods)
      end

      # required for compliance reasons
      def setup(app, *a, &block)
        # logger_middleware = app.use(::Gear::Logger)
        # app.options.logger = Camping::Firewatch.book
        # @logger = app.options.logger = logger_middleware.logger
      end

    end

    # module ClassMethods
    #   # Put syntactic Camping Logging Sugar here.
    #   def log
    #     # either grabs the rack.logger or makes a new logger and returns it.
    #     @env['rack.logger'] ||= ::Logger.new(env['rack.errors'])
    #   end
    # end

    module HelperMethods
      def log
        # either grabs the rack.logger or makes a new logger and returns it.
        @env['rack.logger'] ||= ::Logger.new(env['rack.errors'])
      end
    end

  end

  # Inherit from Rack Logger to get things started.
  class Logger # < Rack::CommonLogger
    def initialize(app, level = ::Logger::INFO)
      @app, @level = app, level
    end

    def call(env)
      # sets up a new logger using rack.errors as the error stream
      logger = ::Logger.new(env['rack.errors'])
      logger.level = @level

      # drops the logger into the rack.logger env spot so that we can grab it
      # down the middleware chain.
      env['rack.logger'] = logger
      @app.call(env)
    ensure
      logger.close
    end

  end

end

# Sets up a default logger file thing
module Camping

  # We make our own logger named firewatch.
  class Firewatch < ::Logger

    class << self

      @logger = nil

      # returns a new logger a specific app, or just the default logger
      def book
        return @logger unless @logger == nil
        file = 'log/camp.log'
        Dir.mkdir 'log' unless Dir.exist? 'log'
        File.open(file, 'w') unless File.exist? file
        @logger ||= Logger.new(file)
      end

    end

  end

end
