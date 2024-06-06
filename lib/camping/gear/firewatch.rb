require 'rack'
require 'rack/utils'
require 'rack/common_logger'
require 'dry/logger'


# Firewatch is Camping's logger.
# It wraps Rack::CommonLogger, and gives a mechanism to Redirect logs.
module Camping
  class Firewatch < Rack::CommonLogger

    class << self
      def logger
        @logger ||= default_logger
      end
      def logger=(new_logger)
        @logger = new_logger
      end
      def default_logger
        Dry.Logger(:Camping, template: default_template).add_backend(stream: "logs/development.log")
      end
      def default_template
        "[<green>%<severity>s</green> - %<time>s] %<message>s"
      end
    end

    # +logger+ can be any object that supports the +write+ or +<<+ methods,
    # which includes the standard library Logger.  These methods are called
    # with a single string argument, the log message.
    # If +logger+ is nil, Firewatch(CommonLogger) will fall back <tt>env['rack.errors']</tt>.
    def initialize(app, logger = nil)
      @app = app
      @logger = Camping::Firewatch.logger = logger.nil? ? Camping::Firewatch.default_logger : logger
    end

  end
end

module Gear

  # Fire watch Gear gives us helper methods to access the logger, log stuff,
  # and do other shenanigans
  module Firewatch

    class << self

      def included(mod)
        mod::Helpers.include(HelperMethods)
      end

      # required for compliance reasons
      def setup(app, *a, &block)
      end

    end

    module HelperMethods

      def logger
        Camping::Firewatch.logger
      end

      # #log A helper method to log stuff.
      # @message: String, Default: nil, An optional value used to directly log
      # rather than requesting the logger
      def log(message = nil)
        return logger unless !message.nil?
        logger.info message
      end
    end

  end

end
