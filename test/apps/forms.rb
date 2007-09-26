require "camping"

Camping.goes :Forms

module Forms
  module Controllers
    class Index < R '/'
      def get; render :index end
    end
    class GetForm
      def get; render :get_form; end
    end
    class GetFormResult
      def get; render :form_result; end
    end
    class PostForm
      def get; render :post_form; end
      def post; render :form_result; end
    end
    class FileForm
      def get; render :file_form; end
      def post; render :form_result; end
    end
  end

  module Views
    def layout
      html do
        head{ title C }
        body do
          ul do
            li{ a "index", :href=>R(Index)}
            li{ a "get form", :href=>R(GetForm)}
            li{ a "post form", :href=>R(PostForm)}
            li{ a "file form", :href=>R(FileForm)}
          end
          p { yield }
        end
      end
    end

    def form_result
      p @input.inspect
    end

    def index
      h1 "Welcome on the Camping test app"
    end

    def get_form
      form :action=>R(GetFormResult), :method=>:get do
        label "Give me your name!", :for=>:name
        input :type=>:text, :name=>:name; br
        input :type=>:text, :name=>"arr[]"; br
        input :type=>:text, :name=>"arr[]"; br
        input :type=>:text, :name=>"hash[x]"; br
        input :type=>:text, :name=>"hash[y]"; br
 
        input :type=>:submit
      end
    end

    def post_form
      form :action=>R(PostForm), :method=>:post do
        label "Give me your name!", :for=>:name
        input :type=>:text, :name=>:name; br
        input :type=>:text, :name=>"arr[]"; br
        input :type=>:text, :name=>"arr[]"; br
        input :type=>:text, :name=>"hash[x]"; br
        input :type=>:text, :name=>"hash[y]"; br
 
        input :type=>:submit
      end
    end

    def file_form
      form :action=>R(FileForm), :method=>:post, :enctype=>"multipart/form-data" do
        input :type=>:text, :name=>"arr"
        input :type=>:text, :name=>"arr"; br
        input :type=>:file, :name=>"first_file"; br
        input :type=>:file, :name=>"files[]"; br
        input :type=>:file, :name=>"files[]"; br
        input :type=>:submit
      end
    end


  end
end

# For CGI
if $0 == __FILE__
  Forms.create
  Forms.run
end
