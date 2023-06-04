require 'camping'

Camping.goes :Loader

$LOAD_PATH << File.dirname(__FILE__)

Camping.goes :Donuts

module Donuts
  module Controllers
    class Index
      def get
        render :index
      end
    end
    class Post
      def get
        render :post
      end
    end
  end

  # how to add a layout to every page
  module Views

    def index
      "_why"
    end

    def post
      "_why"
    end

  end
end
