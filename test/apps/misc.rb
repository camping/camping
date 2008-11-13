require "camping"

Camping.goes :Misc

module Misc
  module Controllers
    class Index < R '/'
      def get; render :index end
    end
    class RenderPartial
      def get; render :_partial; end
    end
    class Xsendfile
      def get
        @headers["X-Sendfile"] = File.expand_path(__FILE__)
        "You shouldn't get this text"
      end
    end
    class Links < R '/links', '/links/(\w+)/with/(\d+)/args'
      def get(*args); render :links; end
    end
    class Redirect
      def get; redirect(RR) end
    end
    class RR
      def get; render :rr; end
    end
    class BadLinks
      def get; render :bad_links; end
    end
    class BadMethod; end
  end

  module Views
    def layout
      html do
        head{ title C }
        body do
          ul do
            li{ a "index", :href=>R(Index)}
            li{ a "render partial", :href=>R(RenderPartial)}
            li{ a "X-Sendfile", :href=>R(Xsendfile)}
            li{ a "Links", :href=>R(Links)}
            li{ a "BadLinks", :href=>R(BadLinks)}
            li{ a "Redirect", :href=>R(Redirect)}
            li{ a "BadMethod", :href=>R(BadMethod)}
          end
          p { yield }
        end
      end
    end

    def _partial
      a "go back to index", :href=>R(Index)
    end

    def index
      h1 "Welcome on the Camping test app"
    end

    def links
      a "plain", :href=>R(Links); br
      a "with args and hash", :href=>R(Links, "moo", 3, :with=>"Hash"); br
      a "with args and mult. hash", :href=>R(Links, "hoi", 8, :with=>"multiple", 3=>"hash"); br
      # TODO : with <AR::Base object
    end

    def bad_links
      a "null controller", :href=>R(nil)
      a "bad arity", :href=>R(RR, :moo)
      a "bad args", :href=>R(Links, 3, "moo")
    end

    def rr
      p "got redirected"
    end


  end
end

# For CGI
if $0 == __FILE__
  Misc.create
  Misc.run
end
