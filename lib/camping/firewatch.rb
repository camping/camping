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
        "[%<severity>s - %<time>s] %<message>s"
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
