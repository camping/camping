#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__) + "/../../lib"
%w(rubygems redcloth camping acts_as_versioned).each { |lib| require lib }

Camping.goes :Tepee

module Tepee::Models
  def self.schema(&block)
    @@schema = block if block_given?
    @@schema
  end
  
  class Page < Base
    PAGE_LINK = /\[\[([^\]|]*)[|]?([^\]]*)\]\]/
    validates_uniqueness_of :title
    before_save { |r| r.title = r.title.underscore }
    acts_as_versioned
  end
end

Tepee::Models.schema do
  create_table :pages, :force => true do |t|
    t.column :title, :string, :limit => 255
    t.column :body, :text
  end
  Tepee::Models::Page.create_versioned_table
end

module Tepee::Controllers
  class Index < R '/'
    def get
      redirect Show, 'home_page'
    end
  end

  class List
    def get
      @pages = Page.find :all, :order => 'title'
      render :list
    end
  end

  class Show < R '/s/(\w+)', '/s/(\w+)/(\d+)'
    def get page_name, version = nil
      redirect(Edit, page_name, 1) and return unless @page = Page.find_by_title(page_name)
      @version = (version.nil? or version == @page.version.to_s) ? @page : @page.versions.find_by_version(version)
      render :show
    end
  end

  class Edit < R '/e/(\w+)/(\d+)', '/e/(\w+)'
    def get page_name, version = nil
      @page = Page.find_or_create_by_title(page_name)
      @page = @page.versions.find_by_version(version) unless version.nil? or version == @page.version.to_s
      render :edit
    end
    
    def post page_name
      Page.find_or_create_by_title(page_name).update_attributes :body => input.post_body and redirect Show, page_name
    end
  end
end

module Tepee::Views
  def layout
    html do
      head do
        title 'test'
      end
      body do
        p do
          small do
            span "welcome to " ; a 'tepee', :href => "http://code.whytheluckystiff.net/svn/camping/trunk/examples/tepee/"
            span '. go ' ;       a 'home',  :href => '/'
            span '. list all ' ; a 'pages', :href => "/list"
          end
        end
        div.content do
          self << yield
        end
      end
    end
  end

  def show
    h1 @page.title
    div { _markup @version.body }
    p do 
      a 'edit',    :href => "/e/#{@version.title}/#{@version.version}"
      a 'back',    :href => "/s/#{@version.title}/#{@version.version-1}" unless @version.version == 1
      a 'next',    :href => "/s/#{@version.title}/#{@version.version+1}" unless @version.version == @page.version
      a 'current', :href => "/s/#{@version.title}" unless @version.version == @page.version
    end
  end

  def edit
    form :method => 'post', :action => "/e/#{@page.title}" do
      p do
        label 'Body' ; br
        textarea @page.body, :name => 'post_body', :rows => 50, :cols => 100
      end
      
      p do
        input :type => 'submit'
        a 'cancel', :href => "/s/#{@page.title}/#{@page.version}"
      end
    end
  end

  def list
    h1 'all pages'
    ul { @pages.each { |p| li { a p.title, :href => "/show/#{p.title}" } } }
  end

  def _markup body
    return '' if body.blank?
    body.gsub!(Tepee::Models::Page::PAGE_LINK) do
      page = title = $1.underscore
      title = $2 unless $2.empty?
      if Tepee::Models::Page.find(:all, :select => 'title').collect { |p| p.title }.include?(page)
        %Q{<a href="/s/#{page}">#{title}</a>}
      else
        %Q{<span>#{title}<a href="/e/#{page}/1">?</a></span>}
      end
    end
    RedCloth.new(body, [ :hard_breaks ]).to_html
  end
end

db_exists = File.exists?('tepee.db')
Tepee::Models::Base.establish_connection :adapter => 'sqlite3', :database => 'tepee.db'
Tepee::Models::Base.logger = Logger.new('camping.log')
ActiveRecord::Schema.define(&Tepee::Models.schema) unless db_exists

if __FILE__ == $0
  Tepee.run
end
