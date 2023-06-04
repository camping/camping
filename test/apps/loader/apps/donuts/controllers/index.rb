module Donuts
  module Controllers
    class Index
      def get
        render :index
      end
    end
  end

  # how to add a layout to every page
  module Views

    def index
      "chunky bacon"
    end

  end
end
