#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + "/../../lib"
require 'camping'
  
module Camping::Models
    class Post < Base; belongs_to :user; end
    class Comment < Base; belongs_to :user; end
    class User < Base; end
end

module Camping::Controllers
    class Index < R '/'
        def get
            @posts = Post.find :all
            render :index
        end
    end
     
    class Add
        def get
            if cookies.user_id
                @session = User.find cookies.user_id
            end
            render :add
        end
        def post
            post = Post.create :title => input.post_title, :body => input.post_body
            redirect View, post
        end
    end

    class Info
        def get
            pre cookies.inspect
        end
    end

    class View < R '/view/(\d+)'
        def get post_id 
            @post = Post.find post_id
            @comments = Comment.find :all, :conditions => ['post_id = ?', post_id]
            render :view
        end
    end
     
    class Edit < R '/edit/(\d+)', '/edit'
        def get post_id 
            if cookies.user_id
                @session = User.find cookies.user_id
            end
            @post = Post.find post_id
            render :edit
        end
     
        def post
            @post = Post.find input.post_id
            @post.update_attributes :title => input.post_title, :body => input.post_body
            redirect View, @post
        end
    end
     
    class Comment
        def post
            Comment.create(:username => input.post_username,
                       :body => input.post_body, :post_id => input.post_id)
            redirect View, input.post_id
        end
    end
     
    class Login
        def post
            @user = User.find :first, :conditions => ['username = ? AND password = ?', input.username, input.password]
     
            if @user
                @login = 'login success !'
                cookies.user_id = @user.id
            else
                @login = 'wrong user name or password'
            end
            render :login
        end
    end
     
    class Logout
        def get
            cookies.user_id = nil
            render :logout
        end
    end
     
    class Style < R '/styles.css', '/view/styles.css'
        def get
            Response.new(200) do
                @header["Content-Type"] = "text/css; charset=utf-8"
                @body = File.read('templates/style.css')
            end
        end
    end
end

module Camping::Views

    def layout
      html do
        head do
          title 'blog'
          link :rel => 'stylesheet', :type => 'text/css', 
               :href => 'styles.css', :media => 'screen'
        end
        body do
          yield
        end
      end
    end

    def index
      for post in @posts
        _post(post)
      end
    end

    def login
      p { b @login }
      p { a 'Continue', :href => '/add' }
    end

    def logout
      p "You have been logged out."
      p { a 'Continue', :href => '/' }
    end

    def add
      if @session
        _form(post, :action => '/add')
      else
        _login
      end
    end

    def edit
      if @session
        _form(post, :action => '/edit')
      else
        _login
      end
    end

    def view
        h1.header { a 'blog', :href => '/' }
        _post(post)

        p "Comment for this post:"
        for c in @comments
          h1 c.username
          p c.body
        end

        form :action => '/comment', :method => 'post' do
          label 'Name', :for => 'post_username'; br
          input :name => 'post_username', :type => 'text'; br
          label 'Comment', :for => 'post_body'; br
          textarea :name => 'post_body' do; end; br
          input :type => 'hidden', :name => 'post_id', :value => post.id
          input :type => 'submit'
        end
    end

    # partials
    def _login
      form :action => '/login', :method => 'post' do
        label 'Username', :for => 'username'; br
        input :name => 'username', :type => 'text'; br

        label 'Password', :for => 'password'; br
        input :name => 'password', :type => 'text'; br

        input :type => 'submit', :name => 'login', :value => 'Login'
      end
    end

    def _post(post)
      h1 post.title
      p post.body
      p do
        a "Edit", :href => "/edit/#{post.id}"
        a "View", :href => "/view/#{post.id}"
      end
    end

    def _form(post, opts)
      p do
        text "You are logged in as #{@session.username} | "
        a 'Logout', :href => '/logout'
      end
      form({:method => 'post'}.merge(opts)) do
        label 'Title', :for => 'post_title'; br
        input :name => 'post_title', :type => 'text', 
              :value => post.title; br

        label 'Body', :for => 'post_body'; br
        textarea post.body, :name => 'post_body'; br

        input :type => 'hidden', :name => 'post_id', :value => post.id
        input :type => 'submit'
      end
    end
end
 
if __FILE__ == $0
    Camping::Models::Base.establish_connection :adapter => 'sqlite3', :database => 'blog3.db'
    Camping::Models::Base.logger = Logger.new('camping.log')
    Camping.run
end
