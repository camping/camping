#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'camping'
require 'camping/ar'
require 'camping/session'
require 'redcloth'

Camping.goes :Blog

module Blog
  include Camping::Session

  module Models
    class Post < Base
      belongs_to :user
      
      before_save do |record|
        cloth = RedCloth.new(record.body)
        cloth.hard_breaks = false
        record.html_body = cloth.to_html
      end
    end
    
    class Comment < Base; belongs_to :user; end
    class User < Base; end

    class BasicFields < V 1.1
      def self.up
        create_table :blog_posts, :force => true do |t|
          t.integer :user_id,          :null => false
          t.string  :title,            :limit => 255
          t.text    :body, :html_body
          t.timestamps 
        end
        create_table :blog_users, :force => true do |t|
          t.string  :username, :password
        end
        create_table :blog_comments, :force => true do |t|
          t.integer :post_id,          :null => false
          t.string  :username
          t.text    :body, :html_body
          t.timestamps
        end
        User.create :username => 'admin', :password => 'camping'
      end
      def self.down
        drop_table :blog_posts
        drop_table :blog_users
        drop_table :blog_comments
      end
    end
  end

  module Controllers
    class Index
      def get
        @posts = Post.all(:order => 'updated_at DESC')
        render :index
      end
    end

    class PostNew
      def get
        require_login!
        @post = Post.new
        render :add
      end
      
      def post
        require_login!
        post = Post.create(:title => input.post_title, :body => input.post_body,
          :user_id => @state.user_id)
        redirect PostN, post
      end
    end

    class PostN
      def get(post_id) 
        @post = Post.find(post_id)
        render :view
      end
    end

    class Edit < R '/post/(\d+)/edit'
      def get(post_id)
        require_login! 
        @post = Post.find(post_id)
        render :edit
      end

      def post(post_id)
        require_login!
        @post = Post.find(post_id)
        @post.update_attributes :title => input.post_title, :body => input.post_body
        redirect PostN, @post  
      end
    end

    class Login
      def get
        @to = input.to
        render :login
      end
      
      def post
        @user = User.find_by_username_and_password(input.username, input.password)
        @to = input.to

        if @user
          @state.user_id = @user.id
          if @to
            redirect @to
          else
            redirect R(Index)
          end
        else
          @info = 'Wrong username or password'
        end
        render :login
      end
    end

    class Logout
      def get
        @state.user_id = nil
        redirect Index
      end
    end

    class Style < R '/styles\.css'
      STYLE = File.read(__FILE__).gsub(/.*__END__/m, '')

      def get
        @headers['Content-Type'] = 'text/css; charset=utf-8'
        STYLE
      end
    end
  end
  
  module Helpers
    def logged_in?
      !!@state.user_id
    end
    
    def require_login!
      unless logged_in?
        redirect X::Login, :to => @env.REQUEST_URI
        throw :halt
      end
    end
  end

  module Views
    def layout
      html do
        head do
          title 'My Blog'
          link :rel => 'stylesheet', :type => 'text/css', 
          :href => '/styles.css', :media => 'screen'
        end
        body do
          h1 { a 'My Blog', :href => R(Index) }
          
          div.wrapper! do
            text yield
          end
          
          hr
          
          p.footer! do
            if logged_in?
              _admin_menu
            else
              a 'Login', :href => R(Login, :to => @env.REQUEST_URI)
              text ' to the adminpanel'
            end
            text ' &ndash; Powered by '
            a 'Camping', :href => 'http://code.whytheluckystiff.net/camping'
          end
        end
      end
    end

    def index
      if @posts.empty?
        h2 'No posts'
        p do
          text 'Could not find any posts. Feel free to '
          a 'add one', :href => R(PostNew)
          text ' yourself'
        end
      else
        @posts.each do |post|
          _post(post)
        end
      end
    end

    def login
      h2 'Login'
      p.info @info if @info
      
      form :action => R(Login), :method => 'post' do
        input :name => 'to', :type => 'hidden', :value => @to if @to
        
        label 'Username', :for => 'username'
        input :name => 'username', :id => 'username', :type => 'text'

        label 'Password', :for => 'password'
        input :name => 'password', :id => 'password', :type => 'password'

        input :type => 'submit', :class => 'submit', :value => 'Login'
      end
    end

    def add
      _form(@post, :action => R(PostNew))
    end

    def edit
      _form(@post, :action => R(Edit, @post))
    end

    def view
      _post(@post)
    end

    # partials
    def _admin_menu
      text [['Log out', R(Logout)], ['New', R(PostNew)]].map { |name, to|
        capture { a name, :href => to}
      }.join(' &ndash; ')
    end

    def _post(post)
      h2 post.title
      p.info do
        text "Written by <strong>#{post.user.username}</strong> "
        text post.updated_at.strftime('%B %M, %Y @ %H:%M ')
        _post_menu(post)
      end
      text post.html_body
    end
    
    def _post_menu(post)
      text '('
      a 'view', :href => R(PostN, post)
      if logged_in?
        text ', '
        a 'edit', :href => R(Edit, post)
      end
      text ')'
    end

    def _form(post, opts)
      form({:method => 'post'}.merge(opts)) do
        label 'Title', :for => 'post_title'
        input :name => 'post_title', :id => 'post_title', :type => 'text', 
              :value => post.title

        label 'Body', :for => 'post_body'
        textarea post.body, :name => 'post_body', :id => 'post_body'

        input :type => 'hidden', :name => 'post_id', :value => post.id
        input :type => 'submit', :class => 'submit', :value => 'Submit'
      end
    end
  end
end

def Blog.create
  Blog::Models.create_schema :assume => (Blog::Models::Post.table_exists? ? 1.0 : 0.0)
end

__END__
* {
  margin: 0;
  padding: 0;
}

body {
  font: normal 14px Arial, 'Bitstream Vera Sans', Helvetica, sans-serif;
  line-height: 1.5;
}

h1, h2, h3, h4 {
  font-family: Georgia, serif;
  font-weight: normal;
}

h1 {  
  background-color: #EEE;
  border-bottom: 5px solid #6F812D;
  outline: 5px solid #9CB441;       
  font-weight: normal;
  font-size: 3em;  
  padding: 0.5em 0;
  text-align: center;
}

h1 a { color: #143D55; text-decoration: none }
h1 a:hover { color: #143D55; text-decoration: underline }

h2 {
  font-size: 2em;
  color: #287AA9;  
}

#wrapper { 
  margin: 3em auto;
  width: 700px;
}

p {
  margin-bottom: 1em;
}

p.info, p#footer {
  color: #999;
  margin-left: 1em;
}

p.info a, p#footer a {
  color: #999;
}

p.info a:hover, p#footer a:hover {
  text-decoration: none;
}

a {
  color: #6F812D;
}

a:hover {
  color: #9CB441;
}

hr {
  border-width: 5px 0;
  border-style: solid;     
  border-color: #9CB441;
  border-bottom-color: #6F812D;
  height: 0;   
}

p#footer {    
  font-size: 0.9em;
  margin: 0;      
  padding: 1em;
  text-align: center;
}

label {  
  display: inline-block;
  width: 100%;
}

input, textarea {     
  margin-bottom: 1em;
  width: 200px;  
}

input.submit {
  float: left;
  width: auto;
}

textarea {
  font: normal 14px Arial, 'Bitstream Vera Sans', Helvetica, sans-serif;
  height: 300px;
  width: 400px;
}

