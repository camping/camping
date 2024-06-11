require 'camping'

Camping.goes :Dummy

module Dummy
  module Models
  end

  module Controllers
    class Index
      def get
        @title = "Dummy"
        render :index
      end
    end
  end

  module Helpers
  end

  module Views

    def layout
      html do
        head do
          title 'Dummy'
          link :rel => 'stylesheet', :type => 'text/css',
          :href => '/styles.css', :media => 'screen'
        end
        body do
          h1 'Dummy'

          div.wrapper! do
            self << yield
          end
        end
      end
    end

    def index
      h2 "Let's go Camping"
    end

  end

end

